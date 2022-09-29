module GherkinParserTest exposing (suite)

import Expect exposing (Expectation)
import Gherkin exposing (FeatureDefinition, FeatureFile, GivenWhenThen(..), Scenario)
import GherkinParser
import Parser
import Test exposing (..)


suite : Test
suite =
    describe "Feature file"
        [ describe "Feature definition"
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
            , test "With a tag" <|
                \_ ->
                    Parser.run GherkinParser.featureDefinition featureDefinition4
                        |> Expect.equal (Ok featureDefinition4Parsed)
            , test "Test a tag" <|
                \_ ->
                    Parser.run GherkinParser.tag "@tag1.0"
                        |> Expect.equal (Ok "@tag1.0")
            ]
        , describe "Scenario definition"
            [ test "Scenario with a step" <|
                \_ ->
                    Parser.run GherkinParser.scenario scenario1
                        |> Expect.equal (Ok scenario1Parsed)
            , test "Scenario with many steps" <|
                \_ ->
                    Parser.run GherkinParser.scenario scenario2
                        |> Expect.equal (Ok scenario2Parsed)
            ]
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


featureDefinition4 : String
featureDefinition4 =
    """
       @tag10
       Feature: Some tagged feature
    Features may have tags.
    """


featureDefinition4Parsed : FeatureDefinition
featureDefinition4Parsed =
    { tagline = [ "@tag10" ]
    , title = "Some tagged feature"
    , description = "Features may have tags."
    }


case3Parsed : FeatureFile
case3Parsed =
    { definition = featureDefinition3Parsed

    --, background = Nothing
    , scenarios =
        [ { tagLine = []
          , title = "The slack"
          , description = ""
          , steps =
                [ { givenWhenThen = Given
                  , argument = "some slack I will love this work"
                  }
                ]
          }
        ]
    }


scenario1 : String
scenario1 =
    """
    Scenario: scenario title!
    Given a single step
    """


scenario1Parsed : Scenario
scenario1Parsed =
    { tagLine = []
    , title = "scenario title!"
    , description = ""
    , steps =
        [ { givenWhenThen = Given
          , argument = "a single step"
          }
        ]
    }


scenario2 : String
scenario2 =
    """
    Scenario: scenario title 2!
    It has a description
    Given a first step
    And another step
    When something is happening
    Then the result is
    But not what you expected
    """


scenario2Parsed : Scenario
scenario2Parsed =
    { tagLine = []
    , title = "scenario title 2!"
    , description = "It has a description\n"
    , steps =
        [ { givenWhenThen = Given
          , argument = "a first step"
          }
        , { givenWhenThen = And
          , argument = "another step"
          }
        , { givenWhenThen = When
          , argument = "something is happening"
          }
        , { givenWhenThen = Then
          , argument = "the result is"
          }
        , { givenWhenThen = But
          , argument = "not what you expected"
          }
        ]
    }
