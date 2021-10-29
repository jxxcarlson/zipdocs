module Evergreen.V47.Document exposing (..)

import Evergreen.V47.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V47.Lang.Lang.Lang
    , title : String
    , public : Bool
    }
