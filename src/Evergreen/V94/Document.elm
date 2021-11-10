module Evergreen.V94.Document exposing (..)

import Evergreen.V94.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V94.Lang.Lang.Lang
    , title : String
    , public : Bool
    , author : Maybe String
    }
