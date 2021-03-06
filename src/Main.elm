module Main exposing (..)

import Browser
import Dict exposing (Dict)
import Html exposing (Html, div, text, input, button)
import Html.Attributes
import Html.Events
import List
import Http
import Json.Decode exposing (Decoder)
import Json.Encode
import Process
import Task

type alias Translations = Dict String String

type SaveButtonState = IsSaving | WasSaved | WasNotSaved | NoSaving

type Model = Loading
  | Error
  | Loaded Translations
  | Saving Translations
  | Saved Translations
  | NotSaved Translations

type Msg = LoadTranslations
  | LoadedTranslations (Result Http.Error Translations)
  | UpdateTranslation String String
  | SaveTranslations
  | SavedTranslations (Result Http.Error ())

-- Http helpers

decodeTranslations : Decoder Translations
decodeTranslations = Json.Decode.dict Json.Decode.string

loadTranslations : Cmd Msg
loadTranslations =
  Http.get {
    url = "https://elm-test.free.beeceptor.com/translations",
    expect = Http.expectJson LoadedTranslations decodeTranslations
  }

serializeTranslations : Translations -> Json.Encode.Value
serializeTranslations translations = (Json.Encode.dict identity Json.Encode.string translations)

saveTranslations : Translations -> Cmd Msg
saveTranslations translations =
  Http.post {
    url = "https://elm-test.free.beeceptor.com/translations",
    body = Http.jsonBody (serializeTranslations translations),
    expect = Http.expectWhatever SavedTranslations
  }

-- View helpers

translationPage : Translations -> SaveButtonState -> Html Msg
translationPage translations saveButtonState =
  div [] [
    translationForm translations,
    translationPageControls saveButtonState
  ]

translationPageControls : SaveButtonState -> Html Msg
translationPageControls saveButtonState =
  case saveButtonState of
    IsSaving -> div [] [ button [Html.Events.onClick SaveTranslations, Html.Attributes.disabled True] [text "Saving..."] ]
    WasSaved -> div [] [ button [Html.Events.onClick SaveTranslations, Html.Attributes.disabled True] [text "✅ Saved!"] ]
    WasNotSaved -> div [] [ button [Html.Events.onClick SaveTranslations, Html.Attributes.disabled True] [text "❌ Error"] ]
    _ -> div [] [ button [Html.Events.onClick SaveTranslations] [text "Save"] ]

translationForm : Translations -> Html Msg
translationForm translations =
  let
    translationEntries = Dict.toList translations
    rows = List.map (\(key, value) -> translationRow key value) translationEntries
  in
    div [Html.Attributes.style "display" "flex", Html.Attributes.style "flex-direction" "column"] rows

translationRow : String -> String -> Html Msg
translationRow key value =
  div [Html.Attributes.style "display" "flex", Html.Attributes.style "flex-direction" "row"] [
    div [] [text key],
    div [] [
      input [
        Html.Attributes.value value,
        Html.Events.onInput (\newValue -> UpdateTranslation key newValue)
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
    Loaded translations -> div [] [ translationPage translations NoSaving ]
    Saving translations -> div [] [ translationPage translations IsSaving ]
    Saved translations -> div [] [ translationPage translations WasSaved ]
    NotSaved translations -> div [] [ translationPage translations WasNotSaved ]
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
    UpdateTranslation key value ->
      case model of
        Loaded translations -> (Loaded (Dict.update key (\_ -> Just value) translations), Cmd.none)
        _ -> (model, Cmd.none)
    SaveTranslations ->
      case model of
        Loaded translations -> (Saving translations, saveTranslations translations)
        _ -> (model, Cmd.none)
    SavedTranslations (Ok ()) ->
      case model of
        Saving translations -> (Saved translations, Process.sleep 2000 |> Task.perform (\_ -> LoadedTranslations (Ok translations)))
        _ -> (model, Cmd.none)
    SavedTranslations (Err httpError) ->
      case model of
        Saving translations -> (NotSaved translations, Process.sleep 2000 |> Task.perform (\_ -> LoadedTranslations (Ok translations)))
        _ -> (model, Cmd.none)

main : Program () Model Msg
main = Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none }
