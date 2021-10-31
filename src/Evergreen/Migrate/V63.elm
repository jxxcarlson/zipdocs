module Evergreen.Migrate.V63 exposing (..)

import Dict
import Evergreen.V62.Authentication
import Evergreen.V62.Credentials
import Evergreen.V62.Document
import Evergreen.V62.Lang.Lang
import Evergreen.V62.Types as Old
import Evergreen.V63.Authentication
import Evergreen.V63.Credentials
import Evergreen.V63.Document
import Evergreen.V63.Lang.Lang
import Evergreen.V63.Types as New
import Lamdera.Migrations exposing (..)


frontendModel : Old.FrontendModel -> ModelMigration New.FrontendModel New.FrontendMsg
frontendModel old =
    ModelUnchanged


backendModel : Old.BackendModel -> ModelMigration New.BackendModel New.BackendMsg
backendModel old =
    ModelMigrated
        ( { message = old.message
          , currentTime = old.currentTime

          -- RANDOM
          , randomSeed = old.randomSeed
          , uuidCount = old.uuidCount
          , randomAtmosphericInt = old.randomAtmosphericInt

          -- USER
          , authenticationDict = identityAuthenticationDict old.authenticationDict

          -- DATA
          , documentDict = identityDocumentDict old.documentDict
          , authorIdDict = old.authorIdDict
          , publicIdDict = old.publicIdDict
          , abstractDict = old.abstractDict
          , usersDocumentsDict = old.usersDocumentsDict
          , publicDocuments = []

          ---- DOCUMENTS
          , documents = List.map identityDocument old.documents
          }
        , Cmd.none
        )


identityAuthenticationDict : Evergreen.V62.Authentication.AuthenticationDict -> Evergreen.V63.Authentication.AuthenticationDict
identityAuthenticationDict old =
    Dict.map (\id value -> identityUserData value) old


identityUserData : Evergreen.V62.Authentication.UserData -> Evergreen.V63.Authentication.UserData
identityUserData old =
    { user = old.user
    , credentials = identityCredentials old.credentials
    }


identityCredentials : Evergreen.V62.Credentials.Credentials -> Evergreen.V63.Credentials.Credentials
identityCredentials (Evergreen.V62.Credentials.V1 a b) =
    Evergreen.V63.Credentials.V1 a b


identityDocumentDict : Old.DocumentDict -> New.DocumentDict
identityDocumentDict old =
    Dict.map (\id value -> identityDocument value) old


identityDocument : Evergreen.V62.Document.Document -> Evergreen.V63.Document.Document
identityDocument old =
    { id = old.id
    , publicId = old.publicId
    , created = old.created
    , modified = old.modified
    , content = old.content
    , language = identityLang old.language
    , title = old.title
    , public = old.public
    , author = Just "jxxcarlson"
    }


identityLang : Evergreen.V62.Lang.Lang.Lang -> Evergreen.V63.Lang.Lang.Lang
identityLang lang =
    case lang of
        Evergreen.V62.Lang.Lang.L1 ->
            Evergreen.V63.Lang.Lang.L1

        Evergreen.V62.Lang.Lang.Markdown ->
            Evergreen.V63.Lang.Lang.Markdown

        Evergreen.V62.Lang.Lang.MiniLaTeX ->
            Evergreen.V63.Lang.Lang.MiniLaTeX


frontendMsg : Old.FrontendMsg -> MsgMigration New.FrontendMsg New.FrontendMsg
frontendMsg old =
    MsgUnchanged


toBackend : Old.ToBackend -> MsgMigration New.ToBackend New.BackendMsg
toBackend old =
    MsgUnchanged


backendMsg : Old.BackendMsg -> MsgMigration New.BackendMsg New.BackendMsg
backendMsg old =
    MsgUnchanged


toFrontend : Old.ToFrontend -> MsgMigration New.ToFrontend New.FrontendMsg
toFrontend old =
    MsgUnchanged
