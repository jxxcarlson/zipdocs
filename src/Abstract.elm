module Abstract exposing (getAbstract, getNormalizedAbstract)

import Lang.Lang as Lang
import Parser exposing ((|.), (|=), Parser)


type alias Abstract =
    { title : String, author : String, abstract : String, tags : String }


getAbstract : Lang.Lang -> String -> Abstract
getAbstract lang source =
    { title = getItem lang "title" source
    , author = getItem lang "author" source
    , abstract = getItem lang "abstract" source
    , tags = getItem lang "tags" source
    }


getNormalizedAbstract : Lang.Lang -> String -> Abstract
getNormalizedAbstract lang source =
    { title = getItem lang "title" source |> String.toLower
    , author = getItem lang "author" source |> String.toLower
    , abstract = getItem lang "abstract" source |> String.toLower
    , tags = getItem lang "tags" source |> String.toLower
    }


getItem : Lang.Lang -> String -> String -> String
getItem lang itemName source =
    case Parser.run (itemParser lang itemName) source of
        Err _ ->
            ""

        Ok str ->
            str


itemParser : Lang.Lang -> String -> Parser String
itemParser lang name =
    case lang of
        Lang.Markdown ->
            annotationParser name

        Lang.MiniLaTeX ->
            macroParser name

        _ ->
            Parser.succeed ""


macroParser : String -> Parser String
macroParser name =
    let
        prefix =
            "\\" ++ name ++ "{"
    in
    Parser.succeed String.slice
        |. Parser.chompUntil prefix
        |. Parser.symbol prefix
        |= Parser.getOffset
        |. Parser.chompUntil "}"
        |= Parser.getOffset
        |= Parser.getSource


annotationParser : String -> Parser String
annotationParser name =
    Parser.succeed String.slice
        |. Parser.chompUntil "[!"
        |. Parser.chompUntil name
        |. Parser.chompUntil "]("
        |. Parser.symbol "]("
        |= Parser.getOffset
        |. Parser.chompUntil ")"
        |= Parser.getOffset
        |= Parser.getSource
