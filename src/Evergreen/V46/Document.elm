module Evergreen.V46.Document exposing (..)

import Evergreen.V46.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V46.Lang.Lang.Lang
    , title : String
    , public : Bool
    }
