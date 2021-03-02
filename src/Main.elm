module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, text)

type alias Translations = Dict String String

type alias Model = Translations

type Msg = ...

init : Model
init = Dict.empty

view : Model -> Html Msg
view model = text "Hello, translations!"

update : Msg -> Model -> Model
update msg model =
  case msg of
    ...

main = Browser.sandbox { init = init, update = update, view = view }
