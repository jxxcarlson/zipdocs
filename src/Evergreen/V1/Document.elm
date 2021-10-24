module Evergreen.V1.Document exposing (..)

import Evergreen.V1.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V1.Lang.Lang.Lang
    }
