module Main exposing (Model, Msg(..), Position, init, update, view)

import Html


type Msg
    = Enter String
    | InitSectorPosition Position
    | ClearQuadrant Position


type alias Model =
    String


type alias Position =
    { row : Int
    , col : Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( "TEST", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.div [] [ Html.text model ]
