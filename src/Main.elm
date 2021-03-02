module Main exposing (..)

import Browser
import Html exposing (Html, text)

type alias Model = ...

type Msg = ...

init : Model
init = ...

view : Model -> Html Msg
view model = text "Hello, translations!"

update : Msg -> Model -> Model
update msg model =
  case msg of
    ...

main = Browser.sandbox { init = init, update = update, view = view }

