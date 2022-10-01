module Fixture exposing (initScenario, lookup, lookupClaims)

import Main
import Spec.Claim as Claim exposing (Claim)
import Spec.Setup as Setup


type alias Context =
    { implementationModel : Main.Model
    }


initScenario init view update =
    Setup.init (init ())
        |> Setup.withView view
        |> Setup.withUpdate update


lookupTable : List ( String, Context -> Context )
lookupTable =
    [ ( "a quadrant at 3,5", aQuadrantAt )
    ]


lookup : String -> (Context -> Context)
lookup key =
    List.filter (\( k, _ ) -> match key k) lookupTable
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault noOp


noOp : Context -> Context
noOp context =
    context


match : String -> String -> Bool
match key k =
    if key == k then
        True

    else
        False


lookupClaimsTable : List ( String, List (Claim Main.Model) )
lookupClaimsTable =
    []


lookupClaims : String -> List (Claim Main.Model)
lookupClaims key =
    List.filter (\( k, _ ) -> match key k) lookupClaimsTable
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault []


aQuadrantAt : Context -> Context
aQuadrantAt context =
    context
