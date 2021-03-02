module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text, input, button)
import Html.Attributes
import Html.Events
import List
import Http
import Json.Decode exposing (Decoder)

type alias Translations = Dict String String

type Model = Loading
  | Error
  | Loaded Translations

type Msg = LoadTranslations
  | LoadedTranslations (Result Http.Error Translations)
--  | UpdateTranslation String String

-- Helpers

decodeTranslations : Decoder Translations
decodeTranslations = Json.Decode.dict Json.Decode.string

loadTranslations : Cmd Msg
loadTranslations =
  Http.get {
    url = "https://elm-test.free.beeceptor.com/translations",
    expect = Http.expectJson LoadedTranslations decodeTranslations
  }

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
      input [
        Html.Attributes.value value
--        , Html.Events.onInput (\newValue -> UpdateTranslation key newValue)
      ] []
    ]
  ]

-- Application specifics

init : () -> (Model, Cmd Msg)
init _ = (Loading, loadTranslations)

view : Model -> Html Msg
view model =
  case model of
    Loading -> div [] [text "Loading..."]
    Loaded translations -> div [] [ translationForm translations ]
    Error -> div [] [text "Error loading translations!"]

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    LoadTranslations ->
      (Loading, loadTranslations)
    LoadedTranslations (Ok translations) ->
      (Loaded translations, Cmd.none)
    LoadedTranslations (Err httpError) ->
      (Error, Cmd.none)
--    UpdateTranslation key value ->
--      (Dict.update key (\_ -> Just value) model, Cmd.none)

main : Program () Model Msg
main = Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }
