module Types exposing (..)

import Abstract exposing (Abstract)
import Authentication exposing (AuthenticationDict)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation exposing (Key)
import Data
import Dict exposing (Dict)
import Document exposing (Document)
import Http
import Lang.Lang
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

    -- USER
    , currentUser : Maybe User
    , inputUsername : String
    , inputPassword : String

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
    , links : List DocumentLink
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

    -- USER
    , authenticationDict : AuthenticationDict

    -- DATA
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublidIdDict
    , abstractDict : AbstractDict
    , links : List DocumentLink

    -- DOCUMENT
    , documents : List Document
    }


type alias DocumentLink =
    { label : String, url : String }


type alias AbstractDict =
    Dict String Abstract


type alias AuthorDict =
    Dict String String


type alias PublidIdDict =
    Dict String String


type alias DocumentDict =
    Dict String Document


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | NoOpFrontendMsg
      -- UI
    | GotNewWindowDimensions Int Int
    | GotViewport Dom.Viewport
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
    | ChangePopupStatus PopupStatus
    | CloseEditor
      -- USER
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
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
      -- USER
    | SignInOrSignUp String String
      -- DOCUMENT
    | SaveDocument Document
    | GetDocumentByAuthorId String
    | GetDocumentByPublicId String
    | CreateDocument Document
    | GetLinks


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
      -- USEr
    | SendUser User
      -- DOCUMENT
    | SendDocument Document
    | SendDocuments (List Document)
    | SendMessage String
    | StatusReport (List String)
    | SetShowEditor Bool
    | GotLinks (List DocumentLink)
