module Evergreen.V7.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Dict
import Evergreen.V7.Abstract
import Evergreen.V7.Document
import Evergreen.V7.Lang.Lang
import Http
import Random
import Time
import Url


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type PrintingState
    = PrintWaiting
    | PrintProcessing
    | PrintReady


type DocumentDeleteState
    = WaitingForDeleteAction


type alias DocumentLink =
    { label : String
    , url : String
    }


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , statusReport : List String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , showEditor : Bool
    , authorId : String
    , currentDocument : Evergreen.V7.Document.Document
    , documents : List Evergreen.V7.Document.Document
    , language : Evergreen.V7.Lang.Lang.Lang
    , inputSearchKey : String
    , printingState : PrintingState
    , documentDeleteState : DocumentDeleteState
    , counter : Int
    , links : List DocumentLink
    }


type alias DocumentDict =
    Dict.Dict String Evergreen.V7.Document.Document


type alias AuthorDict =
    Dict.Dict String String


type alias PublidIdDict =
    Dict.Dict String String


type alias AbstractDict =
    Dict.Dict String Evergreen.V7.Abstract.Abstract


type alias BackendModel =
    { message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublidIdDict
    , abstractDict : AbstractDict
    , links : List DocumentLink
    , documents : List Evergreen.V7.Document.Document
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | GotNewWindowDimensions Int Int
    | GotViewport Browser.Dom.Viewport
    | SetViewPortForElement (Result Browser.Dom.Error ( Browser.Dom.Element, Browser.Dom.Viewport ))
    | ChangePopupStatus PopupStatus
    | ToggleEditor
    | InputText String
    | InputSearchKey String
    | InputAuthorId String
    | NewDocument
    | SetLanguage Evergreen.V7.Lang.Lang.Lang
    | AskFoDocumentById String
    | AskForDocumentByAuthorId
    | ExportToMarkdown
    | ExportToLaTeX
    | Export
    | PrintToPDF
    | GotPdfLink (Result Http.Error String)
    | ChangePrintingState PrintingState
    | FinallyDoCleanPrintArtefacts String
    | Help String


type ToBackend
    = NoOpToBackend
    | RunTask
    | GetStatus
    | SaveDocument Evergreen.V7.Document.Document
    | GetDocumentByAuthorId String
    | GetDocumentByPublicId String
    | CreateDocument Evergreen.V7.Document.Document
    | GetLinks


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendDocument Evergreen.V7.Document.Document
    | SendMessage String
    | StatusReport (List String)
    | SetShowEditor Bool
    | GotLinks (List DocumentLink)
