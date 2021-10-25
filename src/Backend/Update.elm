module Backend.Update exposing (getUserDocuments, gotAtmosphericRandomNumber, setupUser)

import Authentication
import Dict
import Document
import Hex
import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Maybe.Extra
import Random
import Token
import Types exposing (..)
import User exposing (User)


type alias Model =
    BackendModel



-- SYSTEM


gotAtmosphericRandomNumber : Model -> Result error String -> ( Model, Cmd msg )
gotAtmosphericRandomNumber model result =
    case result of
        Ok str ->
            case String.toInt (String.trim str) of
                Nothing ->
                    ( model, broadcast (SendMessage "Could not get atomospheric integer") )

                Just rn ->
                    let
                        newRandomSeed =
                            Random.initialSeed rn
                    in
                    ( { model
                        | randomAtmosphericInt = Just rn
                        , randomSeed = newRandomSeed
                      }
                    , broadcast (SendMessage ("Got atmospheric integer " ++ String.fromInt rn))
                    )

        Err _ ->
            ( model, Cmd.none )



-- USER


setupUser : Model -> ClientId -> String -> String -> ( BackendModel, Cmd BackendMsg )
setupUser model clientId username transitPassword =
    let
        ( randInt, seed ) =
            Random.step (Random.int (Random.minInt // 2) (Random.maxInt - 1000)) model.randomSeed

        randomHex =
            Hex.toString randInt |> String.toUpper

        tokenData =
            Token.get seed

        user =
            { username = username
            , id = tokenData.token
            , realname = "Undefined"
            , email = "Undefined"
            , created = model.currentTime
            , modified = model.currentTime
            }
    in
    case Authentication.insert user randomHex transitPassword model.authenticationDict of
        Err str ->
            ( { model | randomSeed = tokenData.seed }, sendToFrontend clientId (SendMessage ("Error: " ++ str)) )

        Ok authDict ->
            ( { model | randomSeed = tokenData.seed, authenticationDict = authDict, usersDocumentsDict = Dict.insert user.id [] model.usersDocumentsDict }
            , Cmd.batch
                [ sendToFrontend clientId (SendMessage "Success! You have set up your account")
                , sendToFrontend clientId (SendUser user)
                ]
            )


getUserDocuments : User -> UsersDocumentsDict -> DocumentDict -> List Document.Document
getUserDocuments user usersDocumentsDict documentDict =
    case Dict.get user.id usersDocumentsDict of
        Nothing ->
            []

        Just docIds ->
            List.foldl (\id acc -> Dict.get id documentDict :: acc) [] docIds |> Maybe.Extra.values
