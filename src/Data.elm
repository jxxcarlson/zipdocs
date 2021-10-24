module Data exposing
    ( docsNotFound
    , getDocumentByAuthorId
    , getDocumentByPublicId
    , notSignedIn
    )

import Dict exposing (Dict)
import Document exposing (Document, empty)
import Time


documentDict : Dict String Document
documentDict =
    Dict.empty


{-| keys are privateIds of documents, values are document ids
-}
authorIdDict : Dict String String
authorIdDict =
    Dict.empty


{-| keys are publicIds of documents, values are document ids
-}
publicIdDict : Dict String String
publicIdDict =
    Dict.empty



--getDocumentByAuthorId : String -> Maybe Document
--getDocumentByAuthorId authorId =
--    Dict.get authorId authorIdDict |> Maybe.andThen (\k -> Dict.get k documentDict)


getDocumentByAuthorId : String -> Maybe Document
getDocumentByAuthorId authorId =
    let
        maybeId =
            Dict.get authorId authorIdDict

        maybeDoc =
            case maybeId of
                Nothing ->
                    Nothing

                Just id ->
                    Dict.get id documentDict
    in
    maybeDoc


getDocumentByPublicId : String -> Maybe Document
getDocumentByPublicId publicId =
    let
        id =
            Dict.get publicId publicIdDict
    in
    id |> Maybe.andThen (\k -> Dict.get k documentDict)


notSignedIn =
    { empty
        | content = welcomeText
        , id = "id-sys-1"
        , publicId = "public-sys-1"
    }


welcomeText =
    """



[! title](Welcome to ZipTek)


_Use ZipTek to effortlessly create documents in Markdown or MiniLaTeX.  A hassle-free, no-setup way to share small documents with mathematical notation and images (if you need them)._

$$
  \\int_0^1 x^n dx = \\frac{1}{n+1}
$$

*Login.* Not needed.  Just choose your language, click on *New Document*, and start writing.

When you click on _New Document_, you will get two links.  The  first is private; you use it to  edit your document in the future.  Keep this safe!  There is no way to recover it. Documents are automatically saved while you edit

The second link is a public one that you can share with colleagues and
friends.  With it anyone can read your document but not
edit it.

Look in the footer of the app for the links.

![Living near birds can provoke happiness](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRF0zeCqrYUxEmZXRq_IdQtrqlYyAWZ627og&usqp=CAU)


"""


docsNotFound =
    { empty
        | content = docsNotFoundText
        , id = "id-sys-2"
        , publicId = "public-sys-2"
    }


docsNotFoundText =
    """
[title Oops!]

[i  Sorry, could not find your documents]

[i To create a document, press the [b New] button above, on left.]
"""



----XXXX----
