module Styles exposing (..)

import Html.Attributes exposing (..)
import Html exposing (Attribute)

divGrid : List (Attribute msg)
divGrid = [
    style "display" "grid"
    ]

style_center : List (Html.Attribute msg)
style_center = [style "right" "50%", 
                style "bottom" "50%", 
                style "transform" "translateX(50%) translateY(50%)", 
                style "position" "absolute",
                style "text-align" "center"
                ]
center_text : (Html.Attribute msg)
center_text = style "text-align" "center"
