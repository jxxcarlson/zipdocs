module Docs exposing (docsNotFound, notSignedIn)

import Document exposing (Document, empty)


notSignedIn : Document
notSignedIn =
    { empty
        | content = welcomeText
        , id = "id-sys-1"
        , publicId = "public-sys-1"
    }


welcomeText =
    """



[! title](Welcome to Zipdocs)


_Use Zipdocs to effortlessly create documents in Markdown or MiniLaTeX.  A hassle-free, no-setup way to share short notes and articles, problem sets,
 etc. Support for mathematical notation and images.  Export your work to LaTeX, or generate a PDF file._

$$
  \\int_0^1 x^n dx = \\frac{1}{n+1}
$$

*Login.* Not needed.  Just choose your language, click on *New Document*, and start writing.  But if you would like to
set up an account, go for it. (There are some advantages: you don't have to keep track of document links).

When you click on _New Document_, you will get two links.  The  first is private;
use it to  edit your document in the future.  If you are using the no-login option, keep this safe!
There is no way to recover it.

The second link is a public one that you can share with colleagues and
friends.  With it anyone can read your document but not
edit it.  Look in the footer of the app for the links.

Documents are automatically saved as you edit


[Getting the most out of Zipdocs](https://zipdocs.lamdera.app/p/bn493-tt086)

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
