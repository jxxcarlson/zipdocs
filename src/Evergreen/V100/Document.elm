module Evergreen.V100.Document exposing (..)

import Evergreen.V100.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V100.Lang.Lang.Lang
    , title : String
    , public : Bool
    , author : Maybe String
    }
