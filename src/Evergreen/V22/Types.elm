module Evergreen.V22.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Dict
import Evergreen.V22.Abstract
import Evergreen.V22.Authentication
import Evergreen.V22.Document
import Evergreen.V22.Lang.Lang
import Evergreen.V22.User
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
    , currentUser : Maybe Evergreen.V22.User.User
    , inputUsername : String
    , inputPassword : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , showEditor : Bool
    , authorId : String
    , currentDocument : Maybe Evergreen.V22.Document.Document
    , documents : List Evergreen.V22.Document.Document
    , language : Evergreen.V22.Lang.Lang.Lang
    , inputSearchKey : String
    , printingState : PrintingState
    , documentDeleteState : DocumentDeleteState
    , counter : Int
    , links : List DocumentLink
    }


type alias DocumentDict =
    Dict.Dict String Evergreen.V22.Document.Document


type alias AuthorDict =
    Dict.Dict String String


type alias PublidIdDict =
    Dict.Dict String String


type alias AbstractDict =
    Dict.Dict String Evergreen.V22.Abstract.Abstract


type alias BackendModel =
    { message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V22.Authentication.AuthenticationDict
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublidIdDict
    , abstractDict : AbstractDict
    , links : List DocumentLink
    , documents : List Evergreen.V22.Document.Document
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NoOpFrontendMsg
    | GotNewWindowDimensions Int Int
    | GotViewport Browser.Dom.Viewport
    | SetViewPortForElement (Result Browser.Dom.Error ( Browser.Dom.Element, Browser.Dom.Viewport ))
    | ChangePopupStatus PopupStatus
    | CloseEditor
    | OpenEditor
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | InputText String
    | InputSearchKey String
    | InputAuthorId String
    | NewDocument
    | SetDocumentAsCurrent Evergreen.V22.Document.Document
    | SetLanguage Evergreen.V22.Lang.Lang.Lang
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
    | SignInOrSignUp String String
    | SaveDocument (Maybe Evergreen.V22.User.User) Evergreen.V22.Document.Document
    | GetDocumentByAuthorId String
    | GetDocumentByPublicId String
    | CreateDocument (Maybe Evergreen.V22.User.User) Evergreen.V22.Document.Document
    | GetLinks


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendUser Evergreen.V22.User.User
    | SendDocument Evergreen.V22.Document.Document
    | SendDocuments (List Evergreen.V22.Document.Document)
    | SendMessage String
    | StatusReport (List String)
    | SetShowEditor Bool
    | GotLinks (List DocumentLink)