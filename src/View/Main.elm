module View.Main exposing (view)

import Config
import Document exposing (Access(..), Document)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Html exposing (Html)
import Markup.API
import Types exposing (..)
import View.Button as Button
import View.Color as Color
import View.Input
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.9, E.clipX, E.clipY ]
        (mainColumn model)


mainColumn : Model -> Element FrontendMsg
mainColumn model =
    if model.showEditor then
        viewEditorAndRenderedText model

    else if model.statusReport == [] then
        viewRenderedTextOnly model

    else
        viewStatusReport model


viewStatusReport model =
    E.column (mainColumnStyle model)
        [ E.column [ E.centerX, E.spacing 12, E.width (E.px <| smallAppWidth model), E.height (E.px (appHeight_ model)) ]
            [ header model (E.px <| smallAppWidth model)
            , E.column [ E.spacing 8, E.paddingXY 12 12, Font.size 14, Background.color (E.rgb 1 1 1), E.width (E.px (smallAppWidth model)) ]
                (List.map (\item -> E.el [] (E.text item)) model.statusReport)
            , footer model (smallAppWidth model)

            --, footer model 400
            ]
        ]


viewEditorAndRenderedText : Model -> Element FrontendMsg
viewEditorAndRenderedText model =
    E.column (mainColumnStyle model)
        [ E.column [ E.centerX, E.spacing 12, E.width (E.px <| appWidth model), E.height (E.px (appHeight_ model)) ]
            [ header model (E.px <| (appWidth model - 30))
            , E.column [ E.spacing 12 ]
                [ E.row [ E.spacing 12 ]
                    [ viewEditor model (panelWidth_ model)
                    , viewRendered model (panelWidth_ model)
                    ]
                ]
            , footer model (appWidth model - 30)
            ]
        ]


viewRenderedTextOnly : Model -> Element FrontendMsg
viewRenderedTextOnly model =
    E.column (mainColumnStyle model)
        [ E.column [ E.centerX, E.spacing 12, E.width (E.px <| smallAppWidth model), E.height (E.px (appHeight_ model)) ]
            [ header model (E.px <| smallAppWidth model)
            , E.row [ E.spacing 12 ]
                [ E.column [ E.spacing 18 ]
                    [ viewRendered model (smallAppWidth model + 20)
                    ]
                , E.column
                    [ E.width (E.px 300)
                    , E.height (E.px (appHeight_ model - 110))
                    , Font.size 14
                    , Background.color (E.rgb 0.95 0.95 1.0)
                    , E.paddingXY 12 18
                    , Font.color (E.rgb 0.1 0.1 1.0)
                    , E.spacing 8
                    ]
                    (E.el [ Font.size 16, Font.color (E.rgb 0.1 0.1 0.1) ] (E.text "Links to Zipdocs") :: viewLinks model)
                ]
            , footer model (smallAppWidth model)

            --, footer model 400
            ]
        ]


footer model width_ =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (E.px width_)
        , Font.size 14
        ]
        [ Button.exportToLaTeX
        , Button.printToPDF model
        , messageRow model (width_ - 10)
        ]


messageRow model width_ =
    E.row
        [ E.width (E.px (width_ - 200))
        , E.height (E.px 30)
        , E.paddingXY 8 4
        , View.Style.bgGray 0.1
        , View.Style.fgGray 1.0
        ]
        [ E.text model.message ]


header model width_ =
    E.row [ E.spacing 12, E.width width_ ]
        [ Button.newDocument
        , View.Utility.showIf model.showEditor Button.closeEditor
        , Button.miniLaTeXLanguageButton model
        , Button.markupLanguageButton model

        -- , Button.l1LanguageButton model
        , wordCount model
        , View.Utility.showIf (model.currentUser == Nothing) Button.signIn
        , View.Utility.showIf (model.currentUser == Nothing) (View.Input.usernameInput model)
        , View.Utility.showIf (model.currentUser == Nothing) (View.Input.passwordInput model)
        , Button.signOut model

        -- , Button.help
        , E.el [ E.alignRight ] (title Config.appName)
        ]


wordCount : Model -> Element FrontendMsg
wordCount model =
    case model.currentDocument of
        Nothing ->
            E.none

        Just doc ->
            E.el [ Font.size 14, Font.color Color.lightGray ] (E.text <| "words: " ++ (String.fromInt <| Document.wordCount doc))


viewEditor : Model -> Int -> Element FrontendMsg
viewEditor model width_ =
    E.column
        [ E.alignTop
        , E.spacing 8
        ]
        [ viewEditor_ model width_
        ]


viewEditor_ : Model -> Int -> Element FrontendMsg
viewEditor_ model width_ =
    case model.currentDocument of
        Nothing ->
            E.none

        Just doc ->
            Input.multiline
                [ E.height (E.px (panelHeight_ model))
                , E.width (E.px width_)
                , Font.size 14
                , Background.color (E.rgb255 240 241 255)
                ]
                { onChange = InputText
                , text = doc.content
                , placeholder = Nothing
                , label = Input.labelHidden "Enter source text here"
                , spellcheck = False
                }


viewRendered : Model -> Int -> Element FrontendMsg
viewRendered model width_ =
    case model.currentDocument of
        Nothing ->
            E.none

        Just doc ->
            E.column
                [ E.paddingEach { left = 24, right = 24, top = 32, bottom = 96 }
                , View.Style.bgGray 1.0
                , E.width (E.px width_)
                , E.height (E.px (panelHeight_ model))
                , E.centerX
                , Font.size 14
                , E.alignTop
                , E.scrollbarY
                , View.Utility.elementAttribute "id" "__RENDERED_TEXT__"
                ]
                [ View.Utility.katexCSS
                , E.column [ E.spacing 18, E.width (E.px (panelWidth_ model - 60)) ]
                    (Markup.API.renderFancy settings doc.language model.counter (String.lines doc.content))

                --  (Markup.API.compile Markup.API.Markdown model.counter (settings model) (String.lines model.currentDocument.content))
                ]


viewLinks : Model -> List (Element FrontendMsg)
viewLinks model =
    List.map viewLink (List.sortBy (\l -> l.label) model.links)


viewLink : DocumentLink -> Element FrontendMsg
viewLink docLink =
    E.newTabLink [] { url = docLink.url, label = E.el [] (E.text docLink.label) }


settings : Markup.API.Settings
settings =
    { width = 500
    , titleSize = 30
    , showTOC = True
    , showErrorMessages = True
    , paragraphSpacing = 14
    }



--compile : Language -> Int -> Settings -> List String -> List (Element msg)
--compile language generation settings lines


renderArgs model =
    { width = panelWidth_ model - 140
    , selectedId = "foobar"
    , generation = 0
    }



-- DIMENSIONS


panelWidth_ model =
    (appWidth model // 2) - 20


appWidth model =
    ramp 700 1200 model.windowWidth


smallAppWidth model =
    ramp 400 700 model.windowWidth


docListWidth =
    220


ramp a b x =
    if x < a then
        a

    else if x > b then
        b

    else
        x


appHeight_ model =
    model.windowHeight - 50


panelHeight_ model =
    appHeight_ model - 110


appWidth_ model =
    model.windowWidth


mainColumnStyle model =
    [ View.Style.bgGray 0.5
    , E.paddingEach { top = 40, bottom = 20, left = 0, right = 0 }
    , E.width (E.px model.windowWidth)
    , E.height (E.px model.windowHeight)
    ]


title : String -> Element msg
title str =
    E.row [ E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
