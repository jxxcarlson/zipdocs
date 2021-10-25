module Evergreen.V22.Document exposing (..)

import Evergreen.V22.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V22.Lang.Lang.Lang
    , title : String
    , public : Bool
    }
