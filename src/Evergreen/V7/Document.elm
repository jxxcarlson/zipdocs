module Evergreen.V7.Document exposing (..)

import Evergreen.V7.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V7.Lang.Lang.Lang
    }
