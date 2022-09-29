module GherkinParser exposing (featureDefinition, gherkinParser, parse, scenario, tag)

import Gherkin exposing (Background, FeatureDefinition, FeatureFile, GivenWhenThen(..), Scenario, Tag)
import Parser exposing ((|.), (|=), DeadEnd, Parser, Step(..), Trailing(..), andThen, chompIf, chompUntil, chompUntilEndOr, chompWhile, getChompedString, keyword, loop, map, oneOf, spaces, succeed, variable)
import Parser.Extras exposing (many)
import Set


parse : String -> Result (List DeadEnd) FeatureFile
parse contents =
    Parser.run gherkinParser contents


gherkinParser : Parser FeatureFile
gherkinParser =
    succeed FeatureFile
        |. spaces
        |= featureDefinition
        |= scenarios


featureDefinition : Parser FeatureDefinition
featureDefinition =
    succeed FeatureDefinition
        |. spaces
        |= loop [] tagLoop
        |. spaces
        |. keyword "Feature:"
        |. spaces
        |= title
        |= description


tagLoop : List String -> Parser (Step (List String) (List String))
tagLoop state =
    oneOf
        [ succeed (\s -> Loop (s :: state))
            |= tag
        , succeed ()
            |> map (\_ -> Done (List.reverse state))
        ]


tag : Parser Tag
tag =
    succeed identity
        |= variable
            { start = \c -> c == '@'
            , inner = \c -> Char.isAlphaNum c || c == '_' || c == '.'
            , reserved = Set.empty
            }


title : Parser String
title =
    succeed identity
        |. spaces
        |= getChompedString (chompWhile (\c -> c /= '\n'))


description : Parser String
description =
    succeed identity
        |. spaces
        |= descriptionLine
        |> andThen cleanDescription


cleanDescription : String -> Parser String
cleanDescription string =
    string
        |> removeDoubleSpace
        |> String.replace "\n " "\n"
        |> succeed


removeDoubleSpace : String -> String
removeDoubleSpace string =
    if String.contains "  " string then
        String.replace "  " " " string |> removeDoubleSpace

    else
        string


descriptionLine : Parser String
descriptionLine =
    oneOf
        [ untilKeyword "Scenario"
        , untilKeyword "Given"
        , untilEnd
        ]


untilKeyword : String -> Parser String
untilKeyword keyword =
    succeed identity
        |. spaces
        |= getChompedString (chompUntil keyword)


untilEnd : Parser String
untilEnd =
    succeed identity
        |. spaces
        |= loop [] descriptionHelper
        |> andThen mergeLines


descriptionHelper : List String -> Parser (Step (List String) (List String))
descriptionHelper state =
    case state of
        "" :: tail ->
            succeed ()
                |> map (\_ -> Done (List.reverse tail))

        _ ->
            oneOf
                [ succeed (\s -> Loop (s :: state))
                    |= chompLine
                , succeed ()
                    |> map (\_ -> Done (List.reverse state))
                ]


mergeLines : List String -> Parser String
mergeLines lines =
    String.join "\n" lines |> succeed


chompLine : Parser String
chompLine =
    succeed identity
        |. spaces
        |= getChompedString (chompUntilEndOr "\n")


scenarios : Parser (List Scenario)
scenarios =
    succeed identity
        |= many scenario


scenario : Parser Scenario
scenario =
    succeed Scenario
        |= many tag
        |. spaces
        |. keyword "Scenario:"
        |. spaces
        |= title
        |= description
        |= many step


step : Parser Gherkin.Step
step =
    oneOf
        [ parseStep Given "Given"
        , parseStep And "And"
        , parseStep When "When"
        , parseStep Then "Then"
        , parseStep But "But"
        ]


parseStep : GivenWhenThen -> String -> Parser Gherkin.Step
parseStep givenWhenThen key =
    succeed identity
        |. keyword key
        |. spaces
        |= getChompedString (chompUntilEndOr "\n")
        |> andThen (makeStep givenWhenThen)


makeStep : GivenWhenThen -> String -> Parser Gherkin.Step
makeStep givenWhenThen argument =
    Gherkin.Step givenWhenThen argument |> succeed
