module Evergreen.V9.Document exposing (..)

import Evergreen.V9.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V9.Lang.Lang.Lang
    }
