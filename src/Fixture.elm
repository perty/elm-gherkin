module Fixture exposing (Context, ImplementationModel, givenSomeStartFunc)

-- Experimenting how a fixture may work.


type alias ImplementationModel =
    Int


type alias Context =
    { implementationModel : ImplementationModel
    }



-- The key should be an expression. Like "an object located at {int},{int}". Given a step "an object located at 10,55",
-- it should match.


lookupTable : List ( String, Context -> Context )
lookupTable =
    [ ( "Some start function", givenSomeStartFunc )
    ]


lookup : String -> Maybe (Context -> Context)
lookup key =
    List.filter (\( k, _ ) -> match key k) lookupTable
        |> List.head
        |> Maybe.map Tuple.second


match : String -> String -> Bool
match key k =
    if key == k then
        True

    else
        False


executeStep : String -> Context -> Result String Context
executeStep step context =
    case lookup step of
        Just fn ->
            fn context |> Ok

        Nothing ->
            Err ("No fixture found for step: " ++ step)


givenSomeStartFunc : Context -> Context
givenSomeStartFunc context =
    { context | implementationModel = 42 }
