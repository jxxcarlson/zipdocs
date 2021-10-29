module Evergreen.V47.Authentication exposing (..)

import Dict
import Evergreen.V47.Credentials
import Evergreen.V47.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V47.User.User
    , credentials : Evergreen.V47.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
