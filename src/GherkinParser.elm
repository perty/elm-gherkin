module GherkinParser exposing (featureDefinition, gherkinParser, parse)

import Gherkin exposing (Background, FeatureDefinition, FeatureFile, GivenWhenThen(..), Scenario, Tag)
import Parser exposing ((|.), (|=), DeadEnd, Parser, Step(..), andThen, chompIf, chompUntil, chompUntilEndOr, chompWhile, getChompedString, keyword, loop, map, oneOf, spaces, succeed, variable)
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
        |= oneOf
            [  scenarios
            , many chompLine
            ]

scenarios : Parser (List Scenario)
scenarios =
    succeed identity
    |= many scenario

anyLine : Parser ( String)
anyLine =
    succeed identity
    |= getChompedString <|
        |.

featureDefinition : Parser FeatureDefinition
featureDefinition =
    succeed FeatureDefinition
        |= many tag
        |. spaces
        |. keyword "Feature:"
        |. spaces
        |= title
        |= description


tag : Parser Tag
tag =
    succeed identity
        |. keyword "@"
        |= variable
            { start = Char.isAlphaNum
            , inner = \c -> Char.isAlphaNum c || c == '_'
            , reserved = Set.empty
            }
        |. spaces


title : Parser String
title =
    succeed identity
        |. spaces
        |= getChompedString (chompWhile (\c -> c /= '\n'))


description : Parser String
description =
    succeed identity
        |. spaces
        |= loop [] descriptionHelper
        |> andThen mergeLines


descriptionHelper : List String -> Parser (Step (List String) (List String))
descriptionHelper state =
    let
        _ =
            Debug.log "helper" state
    in
    case state of
        "" :: tail ->
            succeed ()
                |> map (\_ -> Done (List.reverse tail))

        head :: tail ->
            if String.startsWith "Scenario: " head then
                succeed ()
                    |> map (\_ -> Done (List.reverse tail))

            else
                oneOf
                    [ succeed (\s -> Loop (s :: state))
                        |= chompLine
                    , succeed ()
                        |> map (\_ -> Done (List.reverse state))
                    ]

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


maybeBackground : Parser (Maybe Background)
maybeBackground =
    succeed Nothing


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
    succeed identity
        |. keyword "Given"
        |= getChompedString (chompUntilEndOr "\n")
        |> andThen makeStep


makeStep : String -> Parser Gherkin.Step
makeStep argument =
    Gherkin.Step Given argument |> succeed
