module Evergreen.V76.Document exposing (..)

import Evergreen.V76.Lang.Lang
import Time


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Evergreen.V76.Lang.Lang.Lang
    , title : String
    , public : Bool
    , author : Maybe String
    }
