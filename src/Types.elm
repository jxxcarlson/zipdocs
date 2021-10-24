module Types exposing (..)

import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation exposing (Key)
import Data
import Dict exposing (Dict)
import Document exposing (Document)
import Http
import Lang.Lang
import Markup.API
import Random
import Time
import Url exposing (Url)
import User exposing (User)


type alias FrontendModel =
    { key : Key
    , url : Url
    , message : String

    -- ADMIN
    , statusReport : List String

    -- UI
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , showEditor : Bool
    , authorId : String

    -- DOCUMENT
    , currentDocument : Document
    , documents : List Document
    , language : Lang.Lang.Lang
    , inputSearchKey : String
    , printingState : PrintingState
    , documentDeleteState : DocumentDeleteState
    , counter : Int
    }


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias BackendModel =
    { message : String
    , currentTime : Time.Posix

    -- RANDOM
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int

    -- DATA
    , documentDict : Dict String Document
    , authorIdDict : Dict String String
    , publicIdDict : Dict String String

    -- DOCUMENT
    , documents : List Document
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
      -- UI
    | GotNewWindowDimensions Int Int
    | GotViewport Dom.Viewport
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | ChangePopupStatus PopupStatus
    | ToggleEditor
      -- USER
      -- DOC
    | InputText String
    | InputSearchKey String
    | InputAuthorId String
    | NewDocument
    | SetLanguage Lang.Lang.Lang
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


type PrintingState
    = PrintWaiting
    | PrintProcessing
    | PrintReady


type DocumentDeleteState
    = WaitingForDeleteAction


type SearchTerm
    = Query String


type ToBackend
    = NoOpToBackend
      -- ADMIN
    | RunTask
    | GetStatus
      -- DOCUMENT
    | SaveDocument Document
    | GetDocumentByAuthorId String
    | GetDocumentByPublicId String
    | CreateDocument Document


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
      -- DOCUMENT
    | SendDocument Document
    | SendMessage String
    | StatusReport (List String)
    | SetShowEditor Bool
