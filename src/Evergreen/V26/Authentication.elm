module Evergreen.V26.Authentication exposing (..)

import Dict
import Evergreen.V26.Credentials
import Evergreen.V26.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V26.User.User
    , credentials : Evergreen.V26.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
