module Evergreen.V60.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Debounce
import Dict
import Evergreen.V60.Abstract
import Evergreen.V60.Authentication
import Evergreen.V60.Document
import Evergreen.V60.Lang.Lang
import Evergreen.V60.Render.Msg
import Evergreen.V60.User
import File
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


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , statusReport : List String
    , inputSpecial : String
    , currentUser : Maybe Evergreen.V60.User.User
    , inputUsername : String
    , inputPassword : String
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , showEditor : Bool
    , authorId : String
    , debounce : Debounce.Debounce String
    , sourceText : String
    , currentDocument : Maybe Evergreen.V60.Document.Document
    , documents : List Evergreen.V60.Document.Document
    , language : Evergreen.V60.Lang.Lang.Lang
    , inputSearchKey : String
    , printingState : PrintingState
    , documentDeleteState : DocumentDeleteState
    , counter : Int
    , publicDocuments : List Evergreen.V60.Document.Document
    }


type alias DocumentDict =
    Dict.Dict String Evergreen.V60.Document.Document


type alias AuthorDict =
    Dict.Dict String String


type alias PublicIdDict =
    Dict.Dict String String


type alias AbstractDict =
    Dict.Dict String Evergreen.V60.Abstract.Abstract


type alias UserId =
    String


type alias DocId =
    String


type alias UsersDocumentsDict =
    Dict.Dict UserId (List DocId)


type alias BackendModel =
    { message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V60.Authentication.AuthenticationDict
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublicIdDict
    , abstractDict : AbstractDict
    , usersDocumentsDict : UsersDocumentsDict
    , publicDocuments : List Evergreen.V60.Document.Document
    , documents : List Evergreen.V60.Document.Document
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
    | InputSpecial String
    | RunSpecial
    | ExportJson
    | JsonRequested
    | JsonSelected File.File
    | JsonLoaded String
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | Render Evergreen.V60.Render.Msg.MarkupMsg
    | InputText String
    | DebounceMsg Debounce.Msg
    | Saved String
    | InputSearchKey String
    | Search
    | InputAuthorId String
    | NewDocument
    | SetDocumentAsCurrent Evergreen.V60.Document.Document
    | SetLanguage Evergreen.V60.Lang.Lang.Lang
    | SetPublic Evergreen.V60.Document.Document Bool
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


type alias BackupOLD =
    { message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int
    , authenticationDict : Evergreen.V60.Authentication.AuthenticationDict
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublicIdDict
    , abstractDict : AbstractDict
    , usersDocumentsDict : UsersDocumentsDict
    , publicDocuments : List Evergreen.V60.Document.Document
    , documents : List Evergreen.V60.Document.Document
    }


type ToBackend
    = NoOpToBackend
    | GetBackupData
    | RunTask
    | GetStatus
    | RestoreBackup BackupOLD
    | SignInOrSignUp String String
    | FetchDocumentById String
    | GetPublicDocuments
    | SaveDocument (Maybe Evergreen.V60.User.User) Evergreen.V60.Document.Document
    | GetDocumentByAuthorId String
    | GetDocumentByPublicId String
    | CreateDocument (Maybe Evergreen.V60.User.User) Evergreen.V60.Document.Document
    | StealDocument Evergreen.V60.User.User String
    | SearchForDocuments String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendBackupData String
    | SendUser Evergreen.V60.User.User
    | SendDocument Evergreen.V60.Document.Document
    | SendDocuments (List Evergreen.V60.Document.Document)
    | SendMessage String
    | StatusReport (List String)
    | SetShowEditor Bool
    | GotPublicDocuments (List Evergreen.V60.Document.Document)
