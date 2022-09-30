module Main exposing (Model, Msg(..), init, update, view)

import Html


type Msg
    = NoOp


type alias Model =
    String


init : () -> ( Model, Cmd Msg )
init _ =
    ( "TEST", Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.div [] [ Html.text model ]
