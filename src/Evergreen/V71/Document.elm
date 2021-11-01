module Evergreen.V71.Document exposing (..)

import Evergreen.V71.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V71.Lang.Lang.Lang
    , title : String
    , public : Bool
    , author : Maybe String
    }
