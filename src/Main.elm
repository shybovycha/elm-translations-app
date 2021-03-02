module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text, input)
import Html.Attributes
import List

type alias Translations = Dict String String

type alias Model = Translations

type Msg = UpdateTranslation String String

-- View helpers
translationForm : Translations -> Html Msg
translationForm model =
  let
    translationEntries = Dict.toList model
    rows = List.map (\(key, value) -> translationRow key value) translationEntries
  in
    div [Html.Attributes.style "display" "flex", Html.Attributes.style "flex-direction" "column"] rows

translationRow : String -> String -> Html Msg
translationRow key value =
  div [Html.Attributes.style "display" "flex", Html.Attributes.style "flex-direction" "row"] [
    div [] [text key],
    div [] [
      input [Html.Attributes.value value] []
    ]
  ]

-- Application stuff

init : Model
init = Dict.fromList [("hello", "cześć"), ("world", "świat")]

view : Model -> Html Msg
view model =
  let
    translations_form = translationForm model
  in
    div [] [translations_form]

update : Msg -> Model -> Model
update msg model =
  case msg of
    UpdateTranslation key value ->
      Dict.update key (\_ -> Just value) model

main = Browser.sandbox { init = init, update = update, view = view }
