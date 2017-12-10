module Errors exposing (main)

{-
   Copyright (c) 2012-present, Evan Czaplicki

   All rights reserved.

   Redistribution and use in source and binary forms, with or without
   modification, are permitted provided that the following conditions are met:

       * Redistributions of source code must retain the above copyright
         notice, this list of conditions and the following disclaimer.

       * Redistributions in binary form must reproduce the above
         copyright notice, this list of conditions and the following
         disclaimer in the documentation and/or other materials provided
         with the distribution.

       * Neither the name of Evan Czaplicki nor the names of other
         contributors may be used to endorse or promote products derived
         from this software without specific prior written permission.

   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
   "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
   A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
   OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
   SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
   LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
   DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
   THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
   (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-}

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import String


main : Program String Model msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }



-- MODEL


type alias Model =
    String


init : String -> ( Model, Cmd msg )
init errorMessage =
    ( errorMessage, Cmd.none )



-- UPDATE


update : msg -> Model -> ( Model, Cmd msg )
update _ model =
    ( model, Cmd.none )



-- VIEW


(=>) : a -> b -> ( a, b )
(=>) =
    (,)


view : Model -> Html msg
view model =
    div
        [ style
            [ "width" => "100%"
            , "min-height" => "100%"
            , "display" => "flex"
            , "flex-direction" => "column"
            , "align-items" => "center"
            , "background-color" => "black"
            , "color" => "rgb(233, 235, 235)"
            , "font-family" => "monospace"
            , "text-align" => "left"
            ]
        ]
        [ div
            [ style
                [ "display" => "block"
                , "white-space" => "pre"
                , "background-color" => "rgb(39, 40, 34)"
                , "padding" => "2em"
                ]
            ]
            (addColors model)
        ]


addColors : String -> List (Html msg)
addColors message =
    message
        |> String.lines
        |> List.concatMap addColorToLine


addColorToLine : String -> List (Html msg)
addColorToLine line =
    flip (++) [ text "\n" ] <|
        if isBreaker line then
            [ colorful "rgb(51, 187, 200)" ("\n\n" ++ line) ]
        else if isBigBreaker line then
            [ colorful "rgb(211, 56, 211)" line ]
        else if isUnderline line then
            [ colorful "#D5200C" line ]
        else if String.startsWith "    " line then
            [ colorful "#9A9A9A" line ]
        else
            processLine line


colorful : String -> String -> Html msg
colorful color msg =
    span [ style [ "color" => color ] ] [ text msg ]


isBreaker : String -> Bool
isBreaker line =
    String.startsWith "-- " line
        && String.contains "----------" line


isBigBreaker : String -> Bool
isBigBreaker line =
    String.startsWith "===============" line


isUnderline : String -> Bool
isUnderline line =
    String.all (\c -> c == ' ' || c == '^') line


isLineNumber : String -> Bool
isLineNumber string =
    String.all (\c -> c == ' ' || Char.isDigit c) string


processLine : String -> List (Html msg)
processLine line =
    case String.split "|" line of
        [] ->
            [ text line ]

        starter :: rest ->
            if not (isLineNumber starter) then
                [ text line ]
            else
                let
                    restOfLine =
                        String.join "|" rest

                    marker =
                        if String.left 1 restOfLine == ">" then
                            colorful "#D5200C" ">"
                        else
                            text " "
                in
                    [ colorful "#9A9A9A" (starter ++ "|")
                    , marker
                    , colorful "#9A9A9A" (String.dropLeft 1 restOfLine)
                    ]
