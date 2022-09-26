module GherkinParser exposing (gherkinParser, parse)

import Gherkin exposing (Background, FeatureDefinition, FeatureFile, ScenarioBase(..), Tag)
import Parser exposing ((|.), (|=), DeadEnd, Parser, chompUntil, getChompedString, keyword, spaces, succeed, variable)
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
        |= maybeBackground
        |= scenarioBases


featureDefinition : Parser FeatureDefinition
featureDefinition =
    succeed FeatureDefinition
        |= many tag
        |. keyword "Feature"
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
        |= getChompedString (chompUntil "\n")


description : Parser String
description =
    succeed identity
        |. spaces
        |= getChompedString (chompUntil "\n")


maybeBackground : Parser (Maybe Background)
maybeBackground =
    succeed Nothing


scenarioBases : Parser (List ScenarioBase)
scenarioBases =
    succeed []
