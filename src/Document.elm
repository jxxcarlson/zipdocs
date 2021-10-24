module Document exposing
    ( Access(..)
    , Document
    , changeSlug
    , dateResidue
    , empty
    , wordCount
    )

import Lang.Lang
import Time
import User exposing (User)


type alias Document =
    { id : String
    , publicId : String
    , created : Time.Posix
    , modified : Time.Posix
    , content : String
    , language : Lang.Lang.Lang
    }


type alias Username =
    String


type Access
    = Public
    | Private
    | Shared { canRead : List Username, canWrite : List Username }


empty =
    { id = "-3"
    , publicId = "-1"
    , created = Time.millisToPosix 0
    , modified = Time.millisToPosix 0
    , content = ""
    , language = Lang.Lang.Markdown
    }


wordCount : Document -> Int
wordCount doc =
    doc.content |> String.words |> List.length
