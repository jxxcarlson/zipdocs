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


makeSlug : Time.Posix -> Document -> String
makeSlug t doc =
    dateResidue t
        |> String.toLower
        |> String.replace " " "-"


changeSlug : String -> String -> String
changeSlug newTitle slug =
    let
        parts =
            String.split "-" slug

        n =
            List.length parts

        dateString =
            List.drop (n - 3) parts |> String.join "-"

        username =
            List.take 1 parts

        titleString =
            newTitle |> String.toLower |> String.replace " " "-"
    in
    [ username, [ titleString ], [ dateString ] ] |> List.concat |> String.join "-"


dateResidue : Time.Posix -> String
dateResidue t =
    let
        y =
            Time.toYear Time.utc t

        m =
            Time.toMonth Time.utc t |> monthAsInt

        d =
            Time.toDay Time.utc t
    in
    [ String.fromInt y, String.fromInt m |> String.padLeft 2 '0', String.fromInt d |> String.padLeft 2 '0' ] |> String.join "-"


monthAsInt : Time.Month -> Int
monthAsInt month =
    case month of
        Time.Jan ->
            1

        Time.Feb ->
            2

        Time.Mar ->
            3

        Time.Apr ->
            4

        Time.May ->
            5

        Time.Jun ->
            6

        Time.Jul ->
            7

        Time.Aug ->
            8

        Time.Sep ->
            9

        Time.Oct ->
            10

        Time.Nov ->
            11

        Time.Dec ->
            12


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
