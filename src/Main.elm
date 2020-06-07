module Main exposing (..)

--IMPORTS

import Styles exposing (..)

import Browser
import Html exposing (Html, Attribute, div, input, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Http exposing (Error, multipartBody,stringPart)

import Material
import Material.Button as Button
import Material.TextField as TextField
import Material.Options as Options 


--CONSTANTS
hubURL : String
hubURL = "http://sync.symphony/hub"

--

--main : Program () Model Msg 
main =
  Browser.element { init = init, update = update, view = view, subscriptions = \_ -> Sub.none}


subscriptions : Model -> Sub Msg
subscriptions model =
    Material.subscriptions Mdc model

-- MODEL
type alias Model =
  { 
      tempo:Int,
      online:Maybe Bool,
      msg : String,
      mdc: Material.Model Msg,
      timeSig: Int
  }


init : () -> ( Model, Cmd Msg )
init _ =
  noCmd {tempo=120, online=Nothing,msg="", mdc=Material.defaultModel,timeSig=4}
  --default 120 BPM 4/4 


-- UPDATE


noCmd : Model -> (Model,Cmd Msg)
noCmd model =
    (model,Cmd.none)

messageHub : Model -> Cmd Msg --checks if online and updates the hub
messageHub model = 
    Http.post
        { url = hubURL
        , body = multipartBody [
           stringPart "tempo" (String.fromInt model.tempo)
          ,stringPart "timeSig" (String.fromInt model.timeSig) -- example: 4 beats in a measure
        ]
        , expect = Http.expectString HubResponse
        }
type Msg
  = UpdateTempo String
  | UpdateHub
  | HubResponse (Result Http.Error String)
  | Mdc (Material.Msg Msg) --for material design updates
  | UpdateTimeSig String


update : Msg -> Model -> (Model,Cmd Msg)
update msg model =
  case msg of
    Mdc msg_ ->
            Material.update Mdc msg_ model
    
    UpdateHub -> 
            ( model, messageHub model)
    HubResponse (Ok _)  -> 
            noCmd {model | online = Just True, msg=""} 
    HubResponse (Err errortype) ->
            noCmd {model | online = Just False, msg= buildErrorMessage <| errortype}
    --Err ->
      --          noCmd {model | online = Just False} 
    UpdateTempo newTempo ->
            case String.toInt newTempo of
                Just validTempo->
                    noCmd { model | tempo = validTempo}
                Nothing ->
                    noCmd {model | msg = "invalid tempo"}
    UpdateTimeSig val->
            case String.toInt val of
                Just validNum ->
                    if validNum > 0 then
                       noCmd {model | timeSig = validNum,msg=""}
                    else
                       noCmd {model | msg = "please enter a number greater than 0"}
                Nothing ->
                    noCmd {model | timeSig = 4 --go to the default value of 4
                          , msg = "please enter a number"}


                    
            
            

isOnline : Maybe Bool -> String       
isOnline status= 
        case status of 
            Just True -> "Is Online"
            Just False -> "Is Offline"
            Nothing -> "Undetermined"

buildErrorMessage : Http.Error -> String
buildErrorMessage httpError =
    case httpError of
        Http.BadUrl message ->
            message

        Http.Timeout ->
            "Check that the hub is online"

        Http.NetworkError ->
            "Make sure you are on the Hub's WiFi network"

        Http.BadStatus statusCode ->
            "Request failed with status code: " ++ String.fromInt statusCode

        Http.BadBody message ->
            message


-- VIEW
view : Model -> Html Msg
view model =
  
  
  div Styles.style_center
    [
     div [] [
         div [] [text <|String.fromInt model.tempo ++ "bpm"],
         input
         [ 
           type_ "range"
           , Html.Attributes.min "30"
           , Html.Attributes.max "240"
           , value <| String.fromInt model.tempo
           , onInput UpdateTempo
         ] []
     ]
     ,div [] [text "Tempo"]
     ,Html.br [] []

     ,TextField.view Mdc "timesig" model.mdc
        [ TextField.type_ "number"
        , Options.onInput UpdateTimeSig
        , TextField.placeholder "4"
        , TextField.fullwidth
        , TextField.nativeControl [Options.attribute <| Styles.center_text] 
        --nativeControl puts on the <input> instead of the <div>, doesn't center text when on the <div>
        ] []
     ,div [] [text "Beats Per Measure"]
     ,Html.br [] []


     ,Button.view Mdc "Update Hub" model.mdc
              [ Button.ripple
              , Options.onClick UpdateHub
              , Button.raised
              ]
              [ text "Update Hub" ]
    , Html.br [] []


    , div [] [text <| isOnline model.online]
    , div [] [text <| model.msg]
    ]
