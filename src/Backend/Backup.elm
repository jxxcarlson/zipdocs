module Backend.Backup exposing (Backup, decodeBackup, encodeBackup)

import Abstract exposing (Abstract)
import Authentication
import Codec exposing (Codec)
import Credentials
import Dict
import Document exposing (Document)
import Lang.Lang exposing (Lang(..))
import Random
import Time
import Types exposing (AbstractDict, AuthorDict, BackendModel, DocumentDict, DocumentLink, PublicIdDict, UsersDocumentsDict)
import User


type alias Backup =
    { message : String
    , currentTime : Time.Posix

    -- RANDOM
    , randomSeed : Random.Seed
    , uuidCount : Int
    , randomAtmosphericInt : Maybe Int

    -- USER
    , authenticationDict : Authentication.AuthenticationDict

    -- DATA
    , documentDict : DocumentDict
    , authorIdDict : AuthorDict
    , publicIdDict : PublicIdDict
    , abstractDict : AbstractDict
    , usersDocumentsDict : UsersDocumentsDict
    , links : List DocumentLink

    --
    ---- DOCUMENTS
    , documents : List Document
    }


backupCodec : Codec Backup
backupCodec =
    Codec.object Backup
        |> Codec.field "message" .message Codec.string
        |> Codec.field "currentTime" .currentTime posixCodec
        -- RANDOM
        |> Codec.field "randomSeed" .randomSeed randomSeedCodec
        |> Codec.field "uuidCount" .uuidCount Codec.int
        |> Codec.field "randomAtmosphericInt" .randomAtmosphericInt (Codec.maybe Codec.int)
        -- USER
        |> Codec.field "authenticationDict" .authenticationDict (Codec.dict userDataCodec)
        -- DATA
        |> Codec.field "documentDict" .documentDict (Codec.dict documentCodec)
        |> Codec.field "authorIdDict" .authorIdDict (Codec.dict Codec.string)
        |> Codec.field "publicIdDict" .publicIdDict (Codec.dict Codec.string)
        |> Codec.field "abstractDict" .abstractDict (Codec.dict abstractCodec)
        |> Codec.field "usersDocumentsDict" .usersDocumentsDict (Codec.dict (Codec.list Codec.string))
        |> Codec.field "links" .links (Codec.list documentLinkCodec)
        ---- DOCUMENTS
        |> Codec.field "documents" .documents (Codec.list documentCodec)
        |> Codec.buildObject


encodeBackup : BackendModel -> String
encodeBackup model =
    let
        backup =
            { message = "backup"
            , currentTime = Time.millisToPosix 0
            , randomSeed = Random.initialSeed 1234
            , uuidCount = model.uuidCount
            , randomAtmosphericInt = model.randomAtmosphericInt
            , authenticationDict = model.authenticationDict
            , documentDict = model.documentDict
            , authorIdDict = model.authorIdDict
            , publicIdDict = model.publicIdDict
            , abstractDict = model.abstractDict
            , usersDocumentsDict = model.usersDocumentsDict
            , links = model.links
            , documents = model.documents
            }
    in
    Codec.encodeToString 4 backupCodec backup



-- decodeBackup : String -> Result Codec.Error BackendModel


decodeBackup str =
    let
        result =
            Codec.decodeString backupCodec str
    in
    case result of
        Ok backup ->
            Ok
                { message = "backup "
                , currentTime = Time.millisToPosix 0

                ---- RANDOM
                , randomSeed = Random.initialSeed 876543
                , uuidCount = 0
                , randomAtmosphericInt = Nothing

                -- USER
                , authenticationDict = backup.authenticationDict
                , documentDict = backup.documentDict
                , authorIdDict = backup.authorIdDict
                , publicIdDict = backup.publicIdDict
                , abstractDict = backup.abstractDict
                , usersDocumentsDict = backup.usersDocumentsDict
                , links = backup.links

                ---- DOCUMENTS
                , documents = []
                }

        Err x ->
            Err x


documentLinkCodec : Codec DocumentLink
documentLinkCodec =
    Codec.object DocumentLink
        |> Codec.field "label" .label Codec.string
        |> Codec.field "url" .url Codec.string
        |> Codec.buildObject


abstractCodec : Codec Abstract
abstractCodec =
    Codec.object Abstract
        |> Codec.field "title" .title Codec.string
        |> Codec.field "author" .author Codec.string
        |> Codec.field "abstract" .abstract Codec.string
        |> Codec.field "tags" .tags Codec.string
        |> Codec.buildObject


authenticationDictCodec : Codec Authentication.AuthenticationDict
authenticationDictCodec =
    Codec.dict userDataCodec


userCodec : Codec User.User
userCodec =
    Codec.object User.User
        |> Codec.field "username" .username Codec.string
        |> Codec.field "id" .id Codec.string
        |> Codec.field "realname" .realname Codec.string
        |> Codec.field "email" .email Codec.string
        |> Codec.field "created" .created posixCodec
        |> Codec.field "modified" .modified posixCodec
        |> Codec.buildObject


credentialsCodec : Codec Credentials.Credentials
credentialsCodec =
    Codec.custom
        (\credentials value ->
            case value of
                Credentials.V1 ss tt ->
                    credentials ss tt
        )
        |> Codec.variant2 "Credentials" Credentials.V1 Codec.string Codec.string
        |> Codec.buildCustom


userDataCodec : Codec Authentication.UserData
userDataCodec =
    Codec.object Authentication.UserData
        |> Codec.field "user" .user userCodec
        |> Codec.field "credentials" .credentials credentialsCodec
        |> Codec.buildObject


documentCodec : Codec Document
documentCodec =
    Codec.object Document
        |> Codec.field "id" .id Codec.string
        |> Codec.field "publicId" .publicId Codec.string
        |> Codec.field "created" .created posixCodec
        |> Codec.field "modified" .modified posixCodec
        |> Codec.field "content" .content Codec.string
        |> Codec.field "language" .language languageCodec
        |> Codec.field "title" .title Codec.string
        |> Codec.field "public" .public Codec.bool
        |> Codec.buildObject


languageCodec : Codec Lang
languageCodec =
    Codec.custom
        (\l1 markdown minilatex value ->
            case value of
                L1 ->
                    l1

                Markdown ->
                    markdown

                MiniLaTeX ->
                    minilatex
        )
        |> Codec.variant0 "L1" L1
        |> Codec.variant0 "Markdown" Markdown
        |> Codec.variant0 "MiniLaTeX" MiniLaTeX
        |> Codec.buildCustom


posixCodec : Codec Time.Posix
posixCodec =
    Codec.map Time.millisToPosix Time.posixToMillis Codec.int


randomSeedCodec : Codec Random.Seed
randomSeedCodec =
    Codec.map Random.initialSeed (\_ -> 0) Codec.int
