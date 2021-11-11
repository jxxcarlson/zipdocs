module Evergreen.V100.Authentication exposing (..)

import Dict
import Evergreen.V100.Credentials
import Evergreen.V100.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V100.User.User
    , credentials : Evergreen.V100.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
