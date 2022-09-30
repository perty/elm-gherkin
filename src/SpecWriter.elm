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
    "module " ++ String.replace " " "_" title ++ " exposing (main)"


imports : String
imports =
    """
    import Fixture
    import Spec
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
    scenarioSuites : List Spec.scenario
    scenarioSuites =
    """
        ++ "["
        ++ (List.map scenarioFuncName scenarios |> String.join ",")
        ++ "]"


scenarioFuncName : Scenario -> String
scenarioFuncName scenario =
    "s" ++ String.replace " " "_" scenario.title
