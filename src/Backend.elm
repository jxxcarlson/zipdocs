module Backend exposing (..)

import Abstract exposing (Abstract)
import Backend.Cmd
import Backend.Update
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

      -- DATA
      , documentDict = Dict.empty
      , authorIdDict = Dict.empty
      , publicIdDict = Dict.empty
      , abstractDict = Dict.empty
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
            Backend.Update.gotAtomsphericRandomNumber model result

        Tick newTime ->
            ( { model | currentTime = newTime } |> updateAbstracts |> makeLinks, Cmd.none )


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
                    "Author link: " ++ Config.appUrl ++ "/a/" ++ authorIdTokenData.token ++ ", Public link:" ++ Config.appUrl ++ "/p/" ++ publicIdTokenData.token
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
                                , sendToFrontend clientId (SendMessage ("public link: " ++ Config.appUrl ++ "/p/" ++ doc.publicId))
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
            Just { label = abstr.title, url = Config.appUrl ++ "/p/" ++ doc.publicId }


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
    { model | abstractDict = abstractDict }


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
