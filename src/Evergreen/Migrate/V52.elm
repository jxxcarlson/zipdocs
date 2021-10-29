module Evergreen.Migrate.V52 exposing (..)

import Dict
import Evergreen.V48.Authentication
import Evergreen.V48.Credentials
import Evergreen.V48.Document
import Evergreen.V48.Lang.Lang
import Evergreen.V48.Types as Old
import Evergreen.V52.Authentication
import Evergreen.V52.Credentials
import Evergreen.V52.Document
import Evergreen.V52.Lang.Lang
import Evergreen.V52.Types as New
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


transformDocumentLink : Old.DocumentLink -> New.DocumentLink
transformDocumentLink old =
    { digest = ""
    , label = old.label
    , url = old.url
    }


identityAuthenticationDict : Evergreen.V48.Authentication.AuthenticationDict -> Evergreen.V52Authentication.AuthenticationDict
identityAuthenticationDict old =
    Dict.map (\id value -> identityUserData value) old


identityUserData : Evergreen.V48.Authentication.UserData -> Evergreen.V52Authentication.UserData
identityUserData old =
    { user = old.user
    , credentials = identityCredentials old.credentials
    }


identityCredentials : Evergreen.V48.Credentials.Credentials -> Evergreen.V52Credentials.Credentials
identityCredentials (Evergreen.V48.Credentials.V1 a b) =
    Evergreen.V52Credentials.V1 a b


identityDocumentDict : Old.DocumentDict -> New.DocumentDict
identityDocumentDict old =
    Dict.map (\id value -> identityDocument value) old


identityDocument : Evergreen.V48.Document.Document -> Evergreen.V52Document.Document
identityDocument old =
    { id = old.id
    , publicId = old.publicId
    , created = old.created
    , modified = old.modified
    , content = old.content
    , language = identityLang old.language
    , title = old.title
    , public = old.public
    }


identityLang : Evergreen.V48.Lang.Lang.Lang -> Evergreen.V52Lang.Lang.Lang
identityLang lang =
    case lang of
        Evergreen.V48.Lang.Lang.L1 ->
            Evergreen.V52Lang.Lang.L1

        Evergreen.V48.Lang.Lang.Markdown ->
            Evergreen.V52Lang.Lang.Markdown

        Evergreen.V48.Lang.Lang.MiniLaTeX ->
            Evergreen.V52Lang.Lang.MiniLaTeX


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
