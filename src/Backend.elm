module Backend exposing (..)

import Abstract exposing (Abstract)
import Authentication
import Backend.Cmd
import Backend.Update
import Cmd.Extra
import Config
import Data
import Dict exposing (Dict)
import Docs
import Document exposing (Access(..))
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import List.Extra
import Maybe.Extra
import Random
import Time
import Token
import Types exposing (..)
import User exposing (User)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Time.every (10 * 1000) Tick
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"

      -- RANDOM
      , randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , randomAtmosphericInt = Nothing
      , currentTime = Time.millisToPosix 0

      -- USER
      , authenticationDict = Dict.empty

      -- DATA
      , documentDict = Dict.empty
      , authorIdDict = Dict.empty
      , publicIdDict = Dict.empty
      , abstractDict = Dict.empty
      , usersDocumentsDict = Dict.empty
      , links = []

      -- DOCUMENTS
      , documents =
            [ Docs.docsNotFound
            , Docs.notSignedIn
            ]
      }
    , Backend.Cmd.getRandomNumber
    )


update : BackendMsg -> Model -> ( Model, Cmd BackendMsg )
update msg model =
    case msg of
        NoOpBackendMsg ->
            ( model, Cmd.none )

        GotAtomsphericRandomNumber result ->
            Backend.Update.gotAtmosphericRandomNumber model result

        Tick newTime ->
            { model | currentTime = newTime } |> updateAbstracts |> makeLinks |> Cmd.Extra.withNoCmd


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        -- ADMIN
        GetBackupData ->
            ( model, Backend.Cmd.exportJson model clientId )

        RestoreBackup backendModel ->
            ( backendModel, sendToFrontend clientId (SendMessage "... data restored from backup") )

        RunTask ->
            ( model, Cmd.none )

        SearchForDocuments key ->
            ( model, sendToFrontend clientId (SendDocuments (searchForDocuments key model)) )

        GetStatus ->
            ( model, sendToFrontend clientId (StatusReport (statusReport model)) )

        -- USER
        SignInOrSignUp username encryptedPassword ->
            case Dict.get username model.authenticationDict of
                Just userData ->
                    if Authentication.verify username encryptedPassword model.authenticationDict then
                        ( model
                        , Cmd.batch
                            [ sendToFrontend clientId (SendDocuments <| Backend.Update.getUserDocuments userData.user model.usersDocumentsDict model.documentDict)
                            , sendToFrontend clientId (SendUser userData.user)
                            ]
                        )

                    else
                        ( model, sendToFrontend clientId (SendMessage <| "Sorry, password and username don't match") )

                Nothing ->
                    Backend.Update.setupUser model clientId username encryptedPassword

        -- DOCUMENTS
        CreateDocument maybeCurrentUser doc_ ->
            let
                idTokenData =
                    Token.get model.randomSeed

                authorIdTokenData =
                    Token.get idTokenData.seed

                publicIdTokenData =
                    Token.get authorIdTokenData.seed

                title =
                    Abstract.getItem doc_.language "title" doc_.content

                doc =
                    { doc_
                        | id = "id-" ++ idTokenData.token
                        , publicId = "pu-" ++ publicIdTokenData.token
                        , created = model.currentTime
                        , modified = model.currentTime
                        , title = title
                    }

                documentDict =
                    Dict.insert ("id-" ++ idTokenData.token) doc model.documentDict

                authorIdDict =
                    Dict.insert ("au-" ++ authorIdTokenData.token) doc.id model.authorIdDict

                publicIdDict =
                    Dict.insert ("pu-" ++ publicIdTokenData.token) doc.id model.publicIdDict

                usersDocumentsDict =
                    case maybeCurrentUser of
                        Nothing ->
                            model.usersDocumentsDict

                        Just user ->
                            let
                                oldIdList =
                                    Dict.get user.id model.usersDocumentsDict |> Maybe.withDefault []
                            in
                            Dict.insert user.id (doc.id :: oldIdList) model.usersDocumentsDict

                message =
                    "Author link: " ++ Config.appUrl ++ "/a/" ++ authorIdTokenData.token ++ ", Public link:" ++ Config.appUrl ++ "/p/" ++ publicIdTokenData.token
            in
            { model
                | randomSeed = publicIdTokenData.seed
                , documentDict = documentDict
                , authorIdDict = authorIdDict
                , publicIdDict = publicIdDict
                , usersDocumentsDict = usersDocumentsDict
            }
                |> Cmd.Extra.withCmds
                    [ sendToFrontend clientId (SendDocument doc)
                    , sendToFrontend clientId (SendMessage message)
                    ]

        SaveDocument currentUser document ->
            let
                --title =
                --   Ab`stract.getItem document.language "title" document.content
                documentDict =
                    Dict.insert document.id document model.documentDict
            in
            ( { model | documentDict = documentDict }, Cmd.none )

        GetDocumentByAuthorId authorId ->
            case Dict.get authorId model.authorIdDict of
                Nothing ->
                    ( model
                    , sendToFrontend clientId (SendMessage "GetDocumentByAuthorId, No docId for that authorId")
                    )

                Just docId ->
                    case Dict.get docId model.documentDict of
                        Nothing ->
                            ( model
                            , sendToFrontend clientId (SendMessage "No document for that docId")
                            )

                        Just doc ->
                            ( model
                            , Cmd.batch
                                [ sendToFrontend clientId (SendDocument doc)
                                , sendToFrontend clientId (SetShowEditor True)
                                , sendToFrontend clientId (SendMessage (Config.appUrl ++ "/p/" ++ doc.publicId))
                                ]
                            )

        GetDocumentByPublicId publicId ->
            case Dict.get publicId model.publicIdDict of
                Nothing ->
                    ( model, sendToFrontend clientId (SendMessage "GetDocumentByPublicId, No docId for that publicId") )

                Just docId ->
                    case Dict.get docId model.documentDict of
                        Nothing ->
                            ( model, sendToFrontend clientId (SendMessage "No document for that docId") )

                        Just doc ->
                            ( model
                            , Cmd.batch
                                [ sendToFrontend clientId (SendDocument doc)
                                , sendToFrontend clientId (SetShowEditor False)
                                , sendToFrontend clientId (SendMessage (Config.appUrl ++ "/p/" ++ doc.publicId ++ ", id = " ++ doc.id))
                                ]
                            )

        GetLinks ->
            ( model, sendToFrontend clientId (GotLinks model.links) )

        StealDocument user id ->
            stealId user id model |> Cmd.Extra.withNoCmd


sendDoc model clientId path =
    case List.head (List.filter (\doc -> doc.publicId == String.dropLeft 3 path) model.documents) of
        Nothing ->
            ( model
            , sendToFrontend clientId (SendMessage <| "Could not find document")
            )

        Just doc ->
            ( model
            , Cmd.batch
                [ sendToFrontend clientId (SendDocument doc)
                ]
            )


postDocumentToCurrentUser : Maybe User -> Document.Document -> Model -> Model
postDocumentToCurrentUser maybeCurrentUser doc model =
    case maybeCurrentUser of
        Nothing ->
            model

        Just user ->
            case Dict.get user.id model.usersDocumentsDict of
                Nothing ->
                    { model | usersDocumentsDict = Dict.insert user.id [ doc.id ] model.usersDocumentsDict }

                Just docIdList ->
                    { model | usersDocumentsDict = Dict.insert user.id (doc.id :: docIdList) model.usersDocumentsDict }


makeLinks : Model -> Model
makeLinks model =
    let
        links =
            List.foldl (\docId acc -> makeLink docId model.documentDict model.abstractDict :: acc) [] (Dict.keys model.documentDict)
    in
    { model | links = Maybe.Extra.values links }


makeLink : String -> DocumentDict -> AbstractDict -> Maybe { label : String, url : String }
makeLink docId documentDict abstractDict =
    case ( Dict.get docId documentDict, Dict.get docId abstractDict ) of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just doc, Just abstr ) ->
            if doc.public then
                Just { label = abstr.title, url = Config.appUrl ++ "/p/" ++ doc.publicId }

            else
                Nothing


statusReport : Model -> List String
statusReport model =
    let
        pairs : List ( String, String )
        pairs =
            Dict.toList model.authorIdDict

        gist documentId =
            Dict.get documentId model.documentDict
                |> Maybe.map .content
                |> Maybe.withDefault "(empty)"
                |> String.trimLeft
                |> String.left 60
                |> String.replace "\n\n" "\n"
                |> String.replace "\n" " ~ "

        items : List String
        items =
            List.map (\( a, b ) -> authorUrl a ++ " : " ++ b ++ " : " ++ gist b) pairs

        abstracts : List String
        abstracts =
            Dict.values model.abstractDict |> List.map Abstract.toString

        firstEntry : String
        firstEntry =
            "Atmospheric Int: " ++ (Maybe.map String.fromInt model.randomAtmosphericInt |> Maybe.withDefault "Nothing")

        secondEntry =
            "Dictionary size: " ++ String.fromInt (List.length pairs)
    in
    firstEntry :: secondEntry :: items ++ abstracts


authorUrl : String -> String
authorUrl authorId =
    Config.appUrl ++ "/a/" ++ authorId


authorLink : String -> String
authorLink authorId =
    "[Author](" ++ authorUrl authorId ++ ")"


publicUrl : String -> String
publicUrl publicId =
    Config.appUrl ++ "/p/" ++ publicId


publicLink : String -> String
publicLink publicId =
    "[Public](" ++ publicUrl publicId ++ ")"


updateAbstracts : Model -> Model
updateAbstracts model =
    let
        ids =
            Dict.keys model.documentDict

        abstractDict =
            List.foldl (\id runningAbstractDict -> putAbstract id model.documentDict runningAbstractDict) model.abstractDict ids
    in
    { model | abstractDict = Backend.Update.updateAbstracts model.documentDict model.abstractDict }


stealId : User -> String -> Model -> Model
stealId user id model =
    case Dict.get id model.documentDict of
        Nothing ->
            model

        Just _ ->
            let
                newUser =
                    user

                newAuthDict =
                    Authentication.updateUser newUser model.authenticationDict
            in
            { model | authenticationDict = newAuthDict }


putAbstract : String -> DocumentDict -> AbstractDict -> AbstractDict
putAbstract docId documentDict abstractDict =
    Dict.insert docId (getAbstract documentDict docId) abstractDict


getAbstract : Dict String Document.Document -> String -> Abstract
getAbstract documentDict id =
    case Dict.get id documentDict of
        Nothing ->
            Abstract.empty

        Just doc ->
            Abstract.get doc.language doc.content


searchInAbstract : String -> Abstract -> Bool
searchInAbstract key abstract =
    String.contains key (Abstract.digestFromAbstract abstract)


filterDict : (value -> Bool) -> Dict comparable value -> List ( comparable, value )
filterDict predicate dict =
    let
        filter key_ dict_ =
            case Dict.get key_ dict_ of
                Nothing ->
                    Nothing

                Just value ->
                    if predicate value then
                        Just ( key_, value )

                    else
                        Nothing

        add key_ dict_ list_ =
            case filter key_ dict_ of
                Nothing ->
                    list_

                Just item ->
                    item :: list_
    in
    List.foldl (\key list_ -> add key dict list_) [] (Dict.keys dict)


searchForDocuments searchKey abstractDict =
    []



--searchForAbstracts : String -> Model -> List ( String, Abstract )
--searchForAbstracts searchKey abstractDict =
--    filterDict (\abstract -> String.contains searchKey (Abstract.getDigest abstract)) model.abstractdict
