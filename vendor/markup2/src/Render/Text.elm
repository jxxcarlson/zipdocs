module Render.Text exposing (render, viewTOC)

import Block.Block exposing (ExprM(..))
import Dict exposing (Dict)
import Element exposing (Element, alignLeft, alignRight, centerX, column, el, newTabLink, px, spacing)
import Element.Background as Background
import Element.Font as Font
import Expression.AST exposing (Expr(..))
import Expression.ASTTools as ASTTools
import LaTeX.MathMacro
import Render.Math
import Render.Settings exposing (Settings)
import Utility


type alias Accumulator =
    { macroDict : LaTeX.MathMacro.MathMacroDict }


render : Int -> Settings -> Accumulator -> ExprM -> Element msg
render generation settings accumulator text =
    case text of
        TextM string _ ->
            Element.el [] (Element.text string)

        ExprM name textList _ ->
            Element.el [] (renderMarked name generation settings accumulator textList)

        VerbatimM name str _ ->
            renderVerbatim name generation settings accumulator str

        ArgM _ _ ->
            Element.none

        ErrorM str ->
            Element.el [ Font.color redColor ] (Element.text str)


errorText index str =
    Element.el [ Font.color (Element.rgb255 200 40 40) ] (Element.text <| "(" ++ String.fromInt index ++ ") not implemented: " ++ str)


renderVerbatim name generation settings accumulator str =
    case Dict.get name verbatimDict of
        Nothing ->
            errorText 1 name

        Just f ->
            f generation settings accumulator str


renderMarked name generation settings accumulator textList =
    case Dict.get name markupDict of
        Nothing ->
            Element.el [ Font.color errorColor ] (Element.text name)

        Just f ->
            f generation settings accumulator textList


markupDict : Dict String (Int -> Settings -> Accumulator -> List ExprM -> Element msg)
markupDict =
    Dict.fromList
        [ ( "special", \g s a textList -> special g s a textList )
        , ( "item", \g s a textList -> item g s a textList )
        , ( "numberedItem", \g s a textList -> numberedItem g s a textList )
        , ( "strong", \g s a textList -> strong g s a textList )
        , ( "bold", \g s a textList -> strong g s a textList )
        , ( "italic", \g s a textList -> italic g s a textList )
        , ( "boldItalic", \g s a textList -> boldItalic g s a textList )
        , ( "red", \g s a textList -> red g s a textList )
        , ( "blue", \g s a textList -> blue g s a textList )
        , ( "violet", \g s a textList -> violet g s a textList )
        , ( "highlight", \g s a textList -> highlight g s a textList )
        , ( "strike", \g s a textList -> strike g s a textList )
        , ( "underline", \g s a textList -> underline g s a textList )
        , ( "gray", \g s a textList -> gray g s a textList )
        , ( "errorHighlight", \g s a textList -> errorHighlight g s a textList )
        , ( "title", \_ _ _ _ -> Element.none )
        , ( "heading1", \g s a textList -> heading1 g s a textList )
        , ( "heading2", \g s a textList -> heading2 g s a textList )
        , ( "heading3", \g s a textList -> heading3 g s a textList )
        , ( "heading4", \g s a textList -> heading4 g s a textList )
        , ( "heading5", \g s a textList -> italic g s a textList )
        , ( "skip", \g s a textList -> skip g s a textList )
        , ( "link", \g s a textList -> link g s a textList )
        , ( "href", \g s a textList -> href g s a textList )
        , ( "image", \g s a textList -> image g s a textList )
        , ( "texmacro", \g s a textList -> texmacro g s a textList )
        , ( "texarg", \g s a textList -> texarg g s a textList )

        -- MiniLaTeX stuff
        , ( "term", \g s a textList -> term g s a textList )
        , ( "emph", \g s a textList -> emph g s a textList )
        , ( "eqref", \g s a textList -> eqref g s a textList )
        , ( "setcounter", \_ _ _ _ -> Element.none )
        ]


verbatimDict : Dict String (Int -> Settings -> Accumulator -> String -> Element msg)
verbatimDict =
    Dict.fromList
        [ ( "$", \g s a str -> math g s a str )
        , ( "`", \g s a str -> code g s a str )
        , ( "code", \g s a str -> code g s a str )
        , ( "math", \g s a str -> math g s a str )
        ]


special : Int -> Settings -> Accumulator -> List ExprM -> Element msg
special g s a textList =
    case textList of
        (TextM functionName _) :: (TextM argString _) :: [] ->
            case Dict.get functionName specialFunctionsDict of
                Nothing ->
                    Element.paragraph []
                        [ Element.el [ Font.color redColor ] (Element.text <| functionName ++ ": ")
                        , Element.el [ Font.color blueColor ] (Element.text argString)
                        ]

                Just f ->
                    f s argString

        _ ->
            Element.paragraph []
                [ Element.el [ Font.color redColor ] (Element.text "Bad syntax for special function")
                ]


specialFunctionsDict : Dict String (Settings -> String -> Element msg)
specialFunctionsDict =
    Dict.fromList
        [ ( "title", \s str -> title s str )
        , ( "red", \s str -> Element.el [ Font.color redColor ] (Element.text str) )
        , ( "blue", \s str -> Element.el [ Font.color blueColor ] (Element.text str) )
        ]


redColor =
    Element.rgb 0.6 0 0.8


blueColor =
    Element.rgb 0 0 0.8


texmacro : Int -> Settings -> Accumulator -> List ExprM -> Element msg
texmacro g s a textList =
    macro1 (\str -> Element.el [] (Element.text ("\\" ++ str))) g s a textList


texarg g s a textList =
    macro1 (\str -> Element.el [] (Element.text ("{" ++ str ++ "}"))) g s a textList


macro1 : (String -> Element msg) -> Int -> Settings -> Accumulator -> List ExprM -> Element msg
macro1 f g s a textList =
    case ASTTools.exprListToStringList textList of
        -- TODO: temporary fix: parse is producing the args in reverse order
        arg1 :: _ ->
            f arg1

        _ ->
            el [ Font.color errorColor ] (Element.text "Invalid arguments")


macro2 : (String -> String -> Element msg) -> Int -> Settings -> Accumulator -> List ExprM -> Element msg
macro2 element g s a textList =
    case ASTTools.exprListToStringList textList of
        -- TODO: temporary fix: parse is producing the args in reverse order
        arg1 :: arg2 :: _ ->
            element arg1 arg2

        _ ->
            el [ Font.color errorColor ] (Element.text "Invalid arguments")


link g s a exprList =
    case exprList of
        (TextM label _) :: (TextM url _) :: _ ->
            link_ url label

        _ ->
            el [ Font.color errorColor ] (Element.text "bad data for link")


link_ : String -> String -> Element msg
link_ url label =
    newTabLink []
        { url = url
        , label = el [ Font.color linkColor ] (Element.text label)
        }


href g s a textList =
    macro2 href_ g s a textList


href_ : String -> String -> Element msg
href_ label url =
    newTabLink []
        { url = url
        , label = el [ Font.color linkColor, Font.italic ] (Element.text <| label)
        }



--         , ( "href", \g s a textList -> href g s a textList )


image generation settings accumuator body =
    let
        arguments =
            ASTTools.exprListToStringList body

        url =
            List.head arguments |> Maybe.withDefault "no-image"

        dict =
            Utility.keyValueDict (List.drop 1 arguments)

        description =
            Dict.get "caption" dict |> Maybe.withDefault ""

        caption =
            case Dict.get "caption" dict of
                Nothing ->
                    Element.none

                Just c ->
                    Element.row [ placement, Element.width Element.fill ] [ el [ Element.width Element.fill ] (Element.text c) ]

        width =
            case Dict.get "width" dict of
                Nothing ->
                    px displayWidth

                Just w_ ->
                    case String.toInt w_ of
                        Nothing ->
                            px displayWidth

                        Just w ->
                            px w

        placement =
            case Dict.get "placement" dict of
                Nothing ->
                    centerX

                Just "left" ->
                    alignLeft

                Just "right" ->
                    alignRight

                Just "center" ->
                    centerX

                _ ->
                    centerX

        displayWidth =
            settings.width
    in
    column [ spacing 8, Element.width (px settings.width), placement, Element.paddingXY 0 18 ]
        [ Element.image [ Element.width width, placement ]
            { src = url, description = description }
        , caption
        ]


errorColor =
    Element.rgb 0.8 0 0


linkColor =
    Element.rgb 0 0 0.8


simpleElement : List (Element.Attribute msg) -> Int -> Settings -> Accumulator -> List ExprM -> Element msg
simpleElement formatList g s a textList =
    Element.paragraph formatList (List.map (render g s a) textList)


verbatimElement formatList g s a str =
    Element.el formatList (Element.text str)


code g s a str =
    verbatimElement codeStyle g s a str


math g s a str =
    mathElement g s a str


codeStyle =
    [ Font.family
        [ Font.typeface "Inconsolata"
        , Font.monospace
        ]
    , Font.color codeColor
    , Element.paddingEach { left = 2, right = 2, top = 0, bottom = 0 }
    ]


mathElement : Int -> Settings -> Accumulator -> String -> Element msg
mathElement generation settings accumulator str =
    Render.Math.mathText generation Render.Math.InlineMathMode (LaTeX.MathMacro.evalStr accumulator.macroDict str)


item : Int -> Settings -> Accumulator -> List ExprM -> Element msg
item generation settings accumulator str =
    Element.paragraph [ Element.width Element.fill ] [ Element.text (ASTTools.exprListToStringList str |> String.join " ") ]


numberedItem : Int -> Settings -> Accumulator -> List ExprM -> Element msg
numberedItem generation settings accumulator str =
    Element.paragraph [ Element.width Element.fill ] [ Element.text (ASTTools.exprListToStringList str |> String.join " ") ]


itemSymbol =
    el [ Font.bold, Element.alignTop, Element.moveUp 1, Font.size 18 ] (Element.text "•")


codeColor =
    -- E.rgb 0.2 0.5 1.0
    Element.rgb 0.4 0 0.8


tocColor =
    Element.rgb 0.1 0 0.8


viewTOC : Int -> Settings -> Accumulator -> List ExprM -> List (Element msg)
viewTOC generation settings accumulator items =
    Element.el [ Font.size 18 ] (Element.text "Contents") :: List.map (viewTOCItem generation settings accumulator) items


internalLink : String -> String
internalLink str =
    "#" ++ str |> makeSlug


tocLink : List ExprM -> Element msg
tocLink textList =
    let
        t =
            ASTTools.stringValueOfList textList
    in
    Element.link [] { url = internalLink t, label = Element.text t }


viewTOCItem : Int -> Settings -> Accumulator -> ExprM -> Element msg
viewTOCItem generation settings accumulator block =
    case block of
        ExprM "heading1" textList _ ->
            el (tocStyle 1 textList) (tocLink textList)

        ExprM "heading2" textList _ ->
            el (tocStyle 2 textList) (tocLink textList)

        ExprM "heading3" textList _ ->
            el (tocStyle 3 textList) (tocLink textList)

        ExprM "heading4" textList _ ->
            el (tocStyle 4 textList) (tocLink textList)

        ExprM "heading5" textList _ ->
            el (tocStyle 5 textList) (tocLink textList)

        _ ->
            Element.none


tocStyle k textList =
    [ Font.size 14, Font.color tocColor, leftPadding (k * tocPadding), makeId textList ]


leftPadding k =
    Element.paddingEach { left = k, right = 0, top = 0, bottom = 0 }


tocPadding =
    8


makeSlug : String -> String
makeSlug str =
    str |> String.toLower |> String.replace " " "-"


makeId : List ExprM -> Element.Attribute msg
makeId textList =
    Utility.elementAttribute "id" (ASTTools.stringValueOfList textList |> String.trim |> makeSlug)


title : Settings -> String -> Element msg
title s titleText =
    -- el [ Font.size s.titleSize, Utility.elementAttribute "id" titleText ] (Element.text titleText)
    Element.none


verticalPadding top bottom =
    Element.paddingEach { top = top, bottom = bottom, left = 0, right = 0 }


headingFontSize settings level =
    let
        factor =
            (sqrt (level + 1) - 0.2) |> min 2.2

        size =
            toFloat settings.titleSize / factor |> round
    in
    Font.size size


heading1 g s a textList =
    Element.column [ headingFontSize s 1, verticalPadding 14 0 ]
        [ Element.link [ makeId textList ]
            { url = internalLink "TITLE", label = Element.paragraph [] (List.map (render g s a) textList) }
        ]


heading2 g s a textList =
    Element.column [ headingFontSize s 2, verticalPadding 14 0 ]
        [ Element.link [ makeId textList ]
            { url = internalLink "TITLE", label = Element.paragraph [] (List.map (render g s a) textList) }
        ]


heading3 g s a textList =
    Element.column [ headingFontSize s 3, verticalPadding 14 0 ]
        [ Element.link [ makeId textList ]
            { url = internalLink "TITLE", label = Element.paragraph [] (List.map (render g s a) textList) }
        ]


heading4 g s a textList =
    Element.column [ headingFontSize s 4, verticalPadding 14 0 ]
        [ Element.link [ makeId textList ]
            { url = internalLink "TITLE", label = Element.paragraph [] (List.map (render g s a) textList) }
        ]


heading5 g s a textList =
    Element.column [ headingFontSize s 5, verticalPadding 14 0 ]
        [ Element.link [ makeId textList ]
            { url = internalLink "TITLE", label = Element.paragraph [] (List.map (render g s a) textList) }
        ]


skip g s a textList =
    let
        numVal : String -> Int
        numVal str =
            String.toInt str |> Maybe.withDefault 0

        f : String -> Element msg
        f str =
            column [ Element.spacingXY 0 (numVal str) ] [ Element.text "" ]
    in
    macro1 f g s a textList


strong g s a textList =
    simpleElement [ Font.bold ] g s a textList


italic g s a textList =
    simpleElement [ Font.italic, Element.paddingEach { left = 0, right = 2, top = 0, bottom = 0 } ] g s a textList


boldItalic g s a textList =
    simpleElement [ Font.italic, Font.bold, Element.paddingEach { left = 0, right = 2, top = 0, bottom = 0 } ] g s a textList


term g s a textList =
    simpleElement [ Font.italic, Element.paddingEach { left = 0, right = 2, top = 0, bottom = 0 } ] g s a textList


eqref g s a textList =
    simpleElement [ Font.italic, Element.paddingEach { left = 0, right = 2, top = 0, bottom = 0 } ] g s a textList


emph g s a textList =
    simpleElement [ Font.italic, Element.paddingEach { left = 0, right = 2, top = 0, bottom = 0 } ] g s a textList


red g s a textList =
    simpleElement [ Font.color (Element.rgb255 200 0 0) ] g s a textList

blue g s a textList =
    simpleElement [ Font.color (Element.rgb255 0 0 200) ] g s a textList


violet g s a textList =
    simpleElement [ Font.color (Element.rgb255 150 100 255) ] g s a textList

highlight g s a textList =
    simpleElement [ Background.color (Element.rgb255 255 255 0) ] g s a textList

strike g s a textList =
    simpleElement [ Font.strike ] g s a textList

underline g s a textList =
    simpleElement [ Font.underline ] g s a textList

gray g s a textList =
    simpleElement [ Font.color (Element.rgb 0.5 0.5 0.5) ] g s a textList



errorHighlight g s a textList =
    simpleElement [ Background.color (Element.rgb255 255 200 200), Element.paddingXY 2 2 ] g s a textList
