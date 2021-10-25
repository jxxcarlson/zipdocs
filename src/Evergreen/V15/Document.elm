module Evergreen.V15.Document exposing (..)

import Evergreen.V15.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V15.Lang.Lang.Lang
    , title : String
    }
