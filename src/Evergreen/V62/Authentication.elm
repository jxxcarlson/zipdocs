module Evergreen.V62.Authentication exposing (..)

import Dict
import Evergreen.V62.Credentials
import Evergreen.V62.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V62.User.User
    , credentials : Evergreen.V62.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
