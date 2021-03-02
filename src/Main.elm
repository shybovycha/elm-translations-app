module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text, input)
import Html.Attributes
import List

type alias Translations = Dict String String

type alias Model = Translations

type Msg = UpdateTranslation String String

init : Model
init = Dict.empty

view : Model -> Html Msg
view model =
  let
    children = List.map (\(key, value) -> div [] [div [] [text key], div [] [input [Html.Attributes.value value] []]]) (Dict.toList model)
  in
    div [] children

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateTranslation key value ->
      Dict.update key (\_ -> Just value) model

main = Browser.sandbox { init = init, update = update, view = view }
