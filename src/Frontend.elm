module Frontend exposing (..)

import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Config
import Data
import Docs
import Document exposing (Access(..))
import File.Download as Download
import Frontend.Cmd
import Frontend.PDF as PDF
import Frontend.Update
import Html exposing (Html)
import LaTeX.Export.API
import Lamdera exposing (sendToBackend)
import Lang.Lang
import List.Extra
import Markup.API
import Process
import Task
import Types exposing (..)
import Url exposing (Url)
import UrlManager
import User
import Util
import View.Main
import View.Utility


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = \m -> Sub.none
        , view = view
        }


subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> GotNewWindowDimensions w h)
        ]


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , url = url
      , message = "Welcome!"

      -- ADMIN
      , statusReport = []

      -- UI
      , windowWidth = 600
      , windowHeight = 900
      , popupStatus = PopupClosed
      , showEditor = False

      -- DOCUMENT
      , counter = 0
      , inputSearchKey = initialSearchKey url
      , authorId = ""
      , documents = [ Docs.notSignedIn ]
      , currentDocument = Docs.notSignedIn
      , printingState = PrintWaiting
      , documentDeleteState = WaitingForDeleteAction
      , language = Lang.Lang.MiniLaTeX
      , links = []
      }
    , Cmd.batch [ Frontend.Cmd.setupWindow, urlAction url.path, sendToBackend GetLinks ]
    )


urlAction path =
    let
        prefix =
            String.left 3 path

        id =
            String.dropLeft 3 path
    in
    if path == "/status/69a1c3be-4971-4673-9e0f-95456fd709a6" then
        sendToBackend GetStatus

    else
        case prefix of
            "/p/" ->
                sendToBackend (GetDocumentByPublicId id)

            "/a/" ->
                sendToBackend (GetDocumentByAuthorId id)

            "/status/69a1c3be-4971-4673-9e0f-95456fd709a6" ->
                sendToBackend GetStatus

            _ ->
                Cmd.none


initialSearchKey : Url -> String
initialSearchKey url =
    if urlIsForGuest url then
        ":public"

    else
        ":me"


urlIsForGuest : Url -> Bool
urlIsForGuest url =
    String.left 2 url.path == "/g"


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    let
                        cmd =
                            case .fragment url of
                                Just internalId ->
                                    -- internalId is the part after '#', if present
                                    View.Utility.setViewportForElement internalId

                                Nothing ->
                                    --if String.left 3 url.path == "/a/" then
                                    sendToBackend (GetDocumentByAuthorId (String.dropLeft 3 url.path))

                        --
                        --else if String.left 3 url.path == "/p/" then
                        --    sendToBackend (GetDocumentByPublicId (String.dropLeft 3 url.path))
                        --
                        --else
                        --    Nav.pushUrl model.key (Url.toString url)
                    in
                    ( model, cmd )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            -- ( model, Cmd.none )
            ( { model | url = url }
            , Cmd.batch
                [ UrlManager.handleDocId url
                ]
            )

        -- UI
        GotNewWindowDimensions w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        GotViewport vp ->
            Frontend.Update.updateWithViewport vp model

        SetViewPortForElement result ->
            case result of
                Ok ( element, viewport ) ->
                    ( model, View.Utility.setViewPortForSelectedLine element viewport )

                Err _ ->
                    ( model, Cmd.none )

        ChangePopupStatus status ->
            ( { model | popupStatus = status }, Cmd.none )

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        ToggleEditor ->
            ( { model | showEditor = not model.showEditor }, Cmd.none )

        Help docId ->
            ( model, sendToBackend (GetDocumentByAuthorId docId) )

        -- DOCUMENT
        InputText str ->
            let
                document =
                    model.currentDocument

                parseData =
                    Markup.API.parse document.language model.counter (String.lines document.content)

                newTitle =
                    Markup.API.getTitle parseData.ast |> Maybe.withDefault "Untitled"

                newDocument =
                    { document | content = str }
            in
            ( { model | currentDocument = newDocument, counter = model.counter + 1 }
            , sendToBackend (SaveDocument document)
            )

        InputAuthorId str ->
            ( { model | authorId = str }, Cmd.none )

        AskFoDocumentById id ->
            ( model, sendToBackend (GetDocumentByAuthorId id) )

        AskForDocumentByAuthorId ->
            ( model, sendToBackend (GetDocumentByAuthorId model.authorId) )

        InputSearchKey str ->
            ( { model | inputSearchKey = str }, Cmd.none )

        NewDocument ->
            Frontend.Update.newDocument model

        SetLanguage lang ->
            ( { model | language = lang }, Cmd.none )

        ExportToMarkdown ->
            let
                markdownText =
                    -- TODO:implement this
                    -- L1.Render.Markdown.transformDocument model.currentDocument.content
                    "Not implemented"

                fileName_ =
                    "foo" |> String.replace " " "-" |> String.toLower |> (\name -> name ++ ".md")
            in
            ( model, Download.string fileName_ "text/markdown" markdownText )

        ExportToLaTeX ->
            let
                laTeXText =
                    LaTeX.Export.API.export model.language model.currentDocument.content

                fileName =
                    "foo" |> String.replace " " "-" |> String.toLower |> (\name -> name ++ ".tex")
            in
            ( model, Download.string fileName "application/x-latex" laTeXText )

        Export ->
            let
                fileName =
                    "doc" |> String.replace " " "-" |> String.toLower |> (\name -> name ++ ".l1")
            in
            ( model, Download.string fileName "text/plain" model.currentDocument.content )

        PrintToPDF ->
            PDF.print model

        GotPdfLink result ->
            PDF.gotLink model result

        ChangePrintingState printingState ->
            let
                cmd =
                    if printingState == PrintWaiting then
                        Process.sleep 1000 |> Task.perform (always (FinallyDoCleanPrintArtefacts model.currentDocument.id))

                    else
                        Cmd.none
            in
            ( { model | printingState = printingState }, cmd )

        FinallyDoCleanPrintArtefacts privateId ->
            ( model, Cmd.none )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        -- DOCUMENT
        SendDocument doc ->
            let
                documents =
                    Util.insertInList doc model.documents

                message =
                    "Documents: " ++ String.fromInt (List.length documents)
            in
            ( { model | currentDocument = doc, language = doc.language, documents = documents }, Cmd.none )

        GotLinks links ->
            ( { model | links = links }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )

        -- ADMIN
        StatusReport items ->
            ( { model | statusReport = items }, Cmd.none )

        SetShowEditor flag ->
            ( { model | showEditor = flag }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = Config.appName
    , body =
        [ View.Main.view model ]
    }
