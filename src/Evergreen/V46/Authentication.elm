module Evergreen.V46.Authentication exposing (..)

import Dict
import Evergreen.V46.Credentials
import Evergreen.V46.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V46.User.User
    , credentials : Evergreen.V46.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
