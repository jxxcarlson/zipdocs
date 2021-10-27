module View.Button exposing
    ( closeEditor
    , export
    , exportToLaTeX
    , exportToMarkown
    , getDocument
    , getDocumentByPrivateId
    , help
    , l1LanguageButton
    , linkTemplate
    , markupLanguageButton
    , miniLaTeXLanguageButton
    , newDocument
    , openEditor
    , printToPDF
    , runSpecial
    , setDocumentAsCurrent
    , signIn
    , signOut
    , startupHelp
    , toggleEditor
    , togglePublic
    )

import Config
import Document exposing (Access(..))
import Element as E exposing (Element)
import Element.Background as Background
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Lang.Lang
import Types exposing (..)
import View.Color as Color
import View.Style
import View.Utility



-- TEMPLATES


buttonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


linkTemplate : msg -> E.Color -> String -> Element msg
linkTemplate msg fontColor label_ =
    E.row [ E.pointer, E.mouseDown [ Background.color Color.paleBlue ] ]
        [ Input.button linkStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14, Font.color fontColor ] (E.text label_)
            }
        ]


linkStyle =
    [ Font.color (E.rgb255 255 255 255)
    , E.paddingXY 8 2
    ]



-- UI


toggleEditor model =
    let
        title =
            if model.showEditor then
                "Hide Editor"

            else
                "Show Editor"
    in
    buttonTemplate [ Background.color Color.darkBlue ] CloseEditor title


signOut model =
    case model.currentUser of
        Nothing ->
            E.none

        Just user ->
            buttonTemplate [] SignOut ("Sign out " ++ user.username)



-- DOCUMENT


getDocumentByPrivateId : Element FrontendMsg
getDocumentByPrivateId =
    buttonTemplate [] AskForDocumentByAuthorId "Get document"


exportToMarkown : Element FrontendMsg
exportToMarkown =
    buttonTemplate [] ExportToMarkdown "Export to Markdown"


exportToLaTeX : Element FrontendMsg
exportToLaTeX =
    buttonTemplate [] ExportToLaTeX "Export to LaTeX"


export : Element FrontendMsg
export =
    buttonTemplate [] Export "Export"


printToPDF : FrontendModel -> Element FrontendMsg
printToPDF model =
    case model.printingState of
        PrintWaiting ->
            buttonTemplate [ View.Utility.elementAttribute "title" "Generate PDF" ] PrintToPDF "PDF"

        PrintProcessing ->
            E.el [ Font.size 14, E.padding 8, E.height (E.px 30), Background.color Color.blue, Font.color Color.white ] (E.text "Please wait ...")

        PrintReady ->
            E.link
                [ Font.size 14
                , Background.color Color.white
                , E.paddingXY 8 8
                , Font.color Color.blue
                , Events.onClick (ChangePrintingState PrintWaiting)
                , View.Utility.elementAttribute "target" "_blank"
                ]
                { url = Config.pdfServer ++ "/pdf/" ++ (Maybe.map .id model.currentDocument |> Maybe.withDefault "???"), label = E.el [] (E.text "Click for PDF") }


newDocument : Element FrontendMsg
newDocument =
    buttonTemplate [] NewDocument "New Document"


closeEditor : Element FrontendMsg
closeEditor =
    buttonTemplate [] CloseEditor "Close Editor"


openEditor : Element FrontendMsg
openEditor =
    buttonTemplate [] OpenEditor "Open Editor"


runSpecial : Element FrontendMsg
runSpecial =
    buttonTemplate [] RunSpecial "Run Special"


help =
    buttonTemplate [] (Help Config.helpDocumentId) "Help"


startupHelp =
    buttonTemplate [] (Help Config.startupHelpDocumentId) "Help"


signIn : Element FrontendMsg
signIn =
    buttonTemplate [] SignIn "Sign in | Sign up"



-- USER


getDocument : Element FrontendMsg
getDocument =
    buttonTemplate [] (AskFoDocumentById "aboutCYT") "Get document"


markupLanguageButton model =
    let
        bg =
            if model.language == Lang.Lang.Markdown then
                Background.color Color.darkRed

            else
                Background.color (E.rgb255 40 40 40)
    in
    buttonTemplate [ bg ] (SetLanguage Lang.Lang.Markdown) "Markdown"


l1LanguageButton model =
    let
        bg =
            if model.language == Lang.Lang.L1 then
                Background.color Color.darkRed

            else
                Background.color (E.rgb255 40 40 40)
    in
    buttonTemplate [ bg ] (SetLanguage Lang.Lang.L1) "L1"


miniLaTeXLanguageButton model =
    let
        bg =
            if model.language == Lang.Lang.MiniLaTeX then
                Background.color Color.darkRed

            else
                Background.color (E.rgb255 40 40 40)
    in
    buttonTemplate [ bg ] (SetLanguage Lang.Lang.MiniLaTeX) "MiniLaTeX"


setDocumentAsCurrent : Maybe Document.Document -> Document.Document -> Element FrontendMsg
setDocumentAsCurrent currentDocument document =
    let
        fg =
            if currentDocument == Just document then
                Font.color (E.rgb 0.7 0 0)

            else
                Font.color (E.rgb 0 0 0.8)

        style =
            if document.public then
                Font.italic

            else
                Font.unitalicized
    in
    Input.button []
        { onPress = Just (SetDocumentAsCurrent document)
        , label = E.el [ E.centerX, E.centerY, Font.size 14, fg, style ] (E.text document.title)
        }


togglePublic : Maybe Document.Document -> Element FrontendMsg
togglePublic maybeDoc =
    case maybeDoc of
        Nothing ->
            E.none

        Just doc ->
            case doc.public of
                False ->
                    buttonTemplate [] (SetPublic doc True) "Private"

                True ->
                    buttonTemplate [] (SetPublic doc False) "Public"



-- buttonTemplate [ Font.size 14, fg, Background.color (E.rgb 0.3 0.3 0.3) ] (SetDocumentAsCurrent document) document.title
