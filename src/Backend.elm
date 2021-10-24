module Backend exposing (..)

import Backend.Cmd
import Backend.Update
import Config
import Data
import Dict
import Docs
import Document exposing (Access(..))
import Lamdera exposing (ClientId, SessionId, sendToFrontend)
import List.Extra
import Random
import Time
import Token
import Types exposing (..)


type alias Model =
    BackendModel


app =
    Lamdera.backend
        { init = init
        , update = update
        , updateFromFrontend = updateFromFrontend
        , subscriptions = \m -> Time.every 10000 Tick
        }


init : ( Model, Cmd BackendMsg )
init =
    ( { message = "Hello!"

      -- RANDOM
      , randomSeed = Random.initialSeed 1234
      , uuidCount = 0
      , randomAtmosphericInt = Nothing
      , currentTime = Time.millisToPosix 0

      -- DATA
      , documentDict = Dict.empty
      , authorIdDict = Dict.empty
      , publicIdDict = Dict.empty

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
            Backend.Update.gotAtomsphericRandomNumber model result

        Tick newTime ->
            ( { model | currentTime = newTime }, Cmd.none )


updateFromFrontend : SessionId -> ClientId -> ToBackend -> Model -> ( Model, Cmd BackendMsg )
updateFromFrontend sessionId clientId msg model =
    case msg of
        NoOpToBackend ->
            ( model, Cmd.none )

        -- ADMIN
        RunTask ->
            ( model, Cmd.none )

        GetStatus ->
            ( model, sendToFrontend clientId (StatusReport (statusReport model)) )

        -- DOCUMENTS
        CreateDocument doc_ ->
            let
                idTokenData =
                    Token.get model.randomSeed

                authorIdTokenData =
                    Token.get idTokenData.seed

                publicIdTokenData =
                    Token.get authorIdTokenData.seed

                doc =
                    { doc_
                        | id = idTokenData.token
                        , publicId = publicIdTokenData.token
                        , created = model.currentTime
                        , modified = model.currentTime
                    }

                documentDict =
                    Dict.insert idTokenData.token doc model.documentDict

                authorIdDict =
                    Dict.insert authorIdTokenData.token doc.id model.authorIdDict

                publicIdDict =
                    Dict.insert publicIdTokenData.token doc.id model.publicIdDict

                message =
                    "Author link: " ++ "https://" ++ Config.appName ++ "/a/" ++ authorIdTokenData.token ++ ", Public link:" ++ "https://" ++ Config.appName ++ "/p/" ++ publicIdTokenData.token
            in
            ( { model | randomSeed = publicIdTokenData.seed, documentDict = documentDict, authorIdDict = authorIdDict, publicIdDict = publicIdDict }
            , Cmd.batch
                [ sendToFrontend clientId (SendDocument doc)
                , sendToFrontend clientId (SendMessage message)
                ]
            )

        SaveDocument document ->
            let
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
                                , sendToFrontend clientId (SendMessage ("public link: https://" ++ Config.appName ++ "/p/" ++ doc.publicId))
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
                            ( model, Cmd.batch [ sendToFrontend clientId (SendDocument doc), sendToFrontend clientId (SetShowEditor False) ] )


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
            List.map (\( a, b ) -> a ++ ": " ++ b ++ " : " ++ gist b) pairs

        firstEntry : String
        firstEntry =
            "Atmospheric Int: " ++ (Maybe.map String.fromInt model.randomAtmosphericInt |> Maybe.withDefault "Nothing")

        secondEntry =
            "Dictionary size: " ++ String.fromInt (List.length pairs)
    in
    firstEntry :: secondEntry :: items
