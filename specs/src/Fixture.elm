module Fixture exposing (initScenario, lookup, lookupClaims)

import Main
import Spec.Claim exposing (Claim)
import Spec.Command as Command
import Spec.Setup as Setup
import Spec.Step as Step exposing (Step)


type alias Context =
    { implementationModel : Main.Model
    }


initScenario init view update =
    Setup.init (init ())
        |> Setup.withView view
        |> Setup.withUpdate update


lookupTable : List ( String, List (Step Main.Model Main.Msg) )
lookupTable =
    [ ( "a quadrant at 3,5", aQuadrantAt )
    , ( "starship is located at sector 3,5", starship_is_located_at_sector )
    ]


lookup : String -> List (Step Main.Model Main.Msg)
lookup key =
    List.filter (\( k, _ ) -> match key k) lookupTable
        |> List.head
        |> Maybe.map Tuple.second
        |> Maybe.withDefault noOp


noOp : List (Step Main.Model Main.Msg)
noOp =
    []


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


sendMsg : Main.Msg -> Step.Context model -> Step.Command Main.Msg
sendMsg msg =
    Command.send <| Command.fake <| msg


aQuadrantAt : List (Step Main.Model Main.Msg)
aQuadrantAt =
    [ sendMsg (Main.Enter "")
    , sendMsg (Main.ClearQuadrant (Main.Position 3 5))
    ]


starship_is_located_at_sector : List (Step Main.Model Main.Msg)
starship_is_located_at_sector =
    [ sendMsg (Main.InitSectorPosition (Main.Position 3 5)) ]
