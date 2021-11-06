module Evergreen.V78.Document exposing (..)

import Evergreen.V78.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V78.Lang.Lang.Lang
    , title : String
    , public : Bool
    , author : Maybe String
    }
