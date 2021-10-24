module Backend.Update exposing (gotAtomsphericRandomNumber)

import Lamdera exposing (ClientId, SessionId, broadcast, sendToFrontend)
import Random
import Types exposing (..)


type alias Model =
    BackendModel



-- SYSTEM


gotAtomsphericRandomNumber : Model -> Result error String -> ( Model, Cmd msg )
gotAtomsphericRandomNumber model result =
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
