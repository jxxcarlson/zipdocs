module Evergreen.V52.Authentication exposing (..)

import Dict
import Evergreen.V52.Credentials
import Evergreen.V52.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V52.User.User
    , credentials : Evergreen.V52.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
