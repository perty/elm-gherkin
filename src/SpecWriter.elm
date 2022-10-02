module SpecWriter exposing (moduleHead, writeSpec)

{-
   Take a FeatureFile data structure and create a spec file.
-}

import Gherkin exposing (FeatureFile, Scenario)


writeSpec : FeatureFile -> String
writeSpec featureFile =
    moduleHead featureFile.definition.title
        ++ imports
        ++ mainSuite featureFile.definition.title
        ++ scenarioSuites featureFile.scenarios


moduleHead : String -> String
moduleHead title =
    "module " ++ String.replace " " "_" title ++ "Spec exposing (main)"


imports : String
imports =
    """

import Fixture
import Runner
import Spec
import Spec.Claim as Claim
import Spec.Observer as Observer
import Main as App

    """


mainSuite : String -> String
mainSuite title =
    """
main =
        Runner.browserProgram
            [ suite ]

suite : Spec.Spec App.Model App.Msg
suite =
        """
        ++ "Spec.describe \""
        ++ title
        ++ "\""
        ++ """
            scenarioSuites
    """


scenarioSuites : List Scenario -> String
scenarioSuites scenarios =
    """
scenarioSuites : List (Spec.Scenario App.Model App.Msg)
scenarioSuites =
    """
        ++ "["
        ++ (List.map scenarioFuncName scenarios |> String.join ",")
        ++ "]"
        ++ (List.map scenarioImplementation scenarios |> String.join " ")


scenarioFuncName : Scenario -> String
scenarioFuncName scenario =
    "s" ++ String.replace " " "_" scenario.title


scenarioImplementation : Scenario -> String
scenarioImplementation scenario =
    "\n\n"
        ++ scenarioFuncName scenario
        ++ " =\n"
        ++ "  Spec.scenario \""
        ++ scenario.title
        ++ "\"\n"
        ++ "   (Spec.given (Fixture.initScenario App.init App.view App.update)\n"
        ++ (List.foldl scenarioStep initState scenario.steps |> .lines)
        ++ "   ))))"


type alias State =
    { seenThen : Bool
    , lines : String
    }


initState : State
initState =
    { seenThen = False
    , lines = ""
    }


scenarioStep : Gherkin.Step -> State -> State
scenarioStep step state =
    case step.givenWhenThen of
        Gherkin.Then ->
            { state
                | seenThen = True
                , lines =
                    state.lines
                        ++ "            |> Spec.it"
                        ++ escapedQuoted step.argument
                        ++ "\n"
                        ++ "                (Observer.observeModel identity\n"
                        ++ "                    |> Spec.expect (Claim.satisfying(\n"
                        ++ "      "
                        ++ stepToClaim step
            }

        _ ->
            if not state.seenThen then
                { state
                    | lines =
                        state.lines
                            ++ "            |> Spec.when "
                            ++ escapedQuoted step.argument
                            ++ "\n"
                            ++ "                (Fixture.lookup "
                            ++ escapedQuoted step.argument
                            ++ ")\n"
                }

            else
                { state
                    | lines = state.lines ++ "              ++ " ++ stepToClaim step
                }


stepToClaim : Gherkin.Step -> String
stepToClaim step =
    "   Fixture.lookupClaims "
        ++ escapedQuoted step.argument
        ++ "\n"


escapedQuoted : String -> String
escapedQuoted argument =
    "\"" ++ String.replace "\"" "\\\"" argument ++ "\""
