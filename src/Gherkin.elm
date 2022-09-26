module Gherkin exposing (Background, FeatureDefinition, FeatureFile, Scenario, ScenarioBase(..), ScenarioOutline, Tag, toString)

-- Data types for a Gherkin document


type alias FeatureFile =
    { definition : FeatureDefinition
    , background : Maybe Background
    , scenarios : List ScenarioBase
    }


type alias FeatureDefinition =
    { tagline : List Tag
    , title : String
    , description : String
    }


type alias Background =
    { description : String
    , steps : List Step
    }


type ScenarioBase
    = Scenario
        { tagLine : List Tag
        , title : String
        , description : String
        , steps : List Step
        }
    | ScenarioOutline
        { tagLine : List Tag
        , title : String
        , description : String
        , steps : List OutlineStep
        , examples : Examples
        }


type alias Examples =
    { tagLine : List Tag
    , description : String
    , table : ExamplesTable
    }


type alias ExamplesTable =
    { head : List String
    , rows : List ExampleRow
    }


type alias ExampleRow =
    { values : List String
    }


type alias Tag =
    String


type alias Step =
    { givenWhenThen : GivenWhenThen
    , argument : String
    }


type alias OutlineStep =
    { givenWhenThen : GivenWhenThen
    , argument : String
    , key : List String
    }


type GivenWhenThen
    = Given
    | When
    | Then


toString : FeatureFile -> String
toString featureFile =
    featureFile.definition.title
