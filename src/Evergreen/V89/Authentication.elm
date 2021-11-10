module Evergreen.V89.Authentication exposing (..)

import Dict
import Evergreen.V89.Credentials
import Evergreen.V89.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V89.User.User
    , credentials : Evergreen.V89.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
