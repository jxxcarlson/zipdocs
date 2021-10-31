module Evergreen.V60.Document exposing (..)

import Evergreen.V60.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V60.Lang.Lang.Lang
    , title : String
    , public : Bool
    }
