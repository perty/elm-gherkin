module GherkinParserTest exposing (suite)

import Expect exposing (Expectation)
import Gherkin exposing (FeatureDefinition, FeatureFile)
import GherkinParser
import Parser
import Test exposing (..)


suite : Test
suite =
    describe "Feature definition"
        [ test "Simple feature definition with a title" <|
            \_ ->
                Parser.run GherkinParser.featureDefinition featureDefinition1
                    |> Expect.equal (Ok featureDefinition1Parsed)
        , test "With a title and a description" <|
            \_ ->
                Parser.run GherkinParser.featureDefinition featureDefinition2
                    |> Expect.equal (Ok featureDefinition2Parsed)
        , test "With a title and a description that ends with a keyword" <|
            \_ ->
                Parser.run GherkinParser.featureDefinition featureDefinition3
                    |> Expect.equal (Ok featureDefinition3Parsed)
        , test "Verify scenario can follow" <|
            \_ ->
                Parser.run GherkinParser.gherkinParser featureDefinition3
                    |> Expect.equal (Ok case3Parsed)
        ]


featureDefinition1 : String
featureDefinition1 =
    """
       Feature: Some 1st feature

    """


featureDefinition1Parsed : FeatureDefinition
featureDefinition1Parsed =
    { tagline = []
    , title = "Some 1st feature"
    , description = ""
    }


featureDefinition2 : String
featureDefinition2 =
    """
       Feature: Some 2nd feature
       Here is the description and it can be several lines.

       The descriptions last line

    """


featureDefinition2Parsed : FeatureDefinition
featureDefinition2Parsed =
    { tagline = []
    , title = "Some 2nd feature"
    , description = "Here is the description and it can be several lines.\nThe descriptions last line"
    }


featureDefinition3 : String
featureDefinition3 =
    """
       Feature: Some 3rd feature
       Here is the description and it can be several lines.

       The descriptions last line
       Scenario: The slack
       Given some slack I will love this work
    """


featureDefinition3Parsed : FeatureDefinition
featureDefinition3Parsed =
    { tagline = []
    , title = "Some 3rd feature"
    , description = "Here is the description and it can be several lines.\n\nThe descriptions last line\n"
    }


case3Parsed : FeatureFile
case3Parsed =
    { definition = featureDefinition3Parsed

    --, background = Nothing
    , scenarios =
        [ { tagLine = []
          , title = "The slack"
          , description = "TODO"
          , steps = []
          }
        ]
    }
