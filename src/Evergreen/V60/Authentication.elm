module Evergreen.V60.Authentication exposing (..)

import Dict
import Evergreen.V60.Credentials
import Evergreen.V60.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V60.User.User
    , credentials : Evergreen.V60.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
