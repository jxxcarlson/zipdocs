module Evergreen.V78.Authentication exposing (..)

import Dict
import Evergreen.V78.Credentials
import Evergreen.V78.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V78.User.User
    , credentials : Evergreen.V78.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
