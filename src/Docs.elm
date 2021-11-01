module Docs exposing (docsNotFound, notSignedIn)

import Document exposing (Document, empty)
import Lang.Lang exposing (Lang(..))


notSignedIn : Document
notSignedIn =
    { empty
        | content = welcomeText
        , id = "id-sys-1"
        , publicId = "public-sys-1"
        , language = MiniLaTeX
    }


welcomeText =
    """

\\title{Welcome to Zipdocs}


\\italic{Use Zipdocs to effortlessly create documents in Markdown or MiniLaTeX.  A hassle-free, no-setup way to share short notes and articles, problem sets,
 etc. Support for mathematical notation and images.  Export your work to LaTeX, or generate a PDF file.}

$$
  \\int_0^1 x^n dx = \\frac{1}{n+1}
$$

\\strong{Login.} Not needed.  Just choose your language, click on \\strong{New}, and start writing.  But if you would like to
set up an account, just enter your username and password in the header and click on \\strong{Sign in | Sign up}.  With
an account, you have a searchable list of all your
documents, and you don't have to keep track of document links.

When you click on \\strong{New} to make a new document, you will get two links, which you will find in the footer of this app. The  first is private;
use it to  edit your document in the future.  If you are using the no-login option, keep this link safe!
There is no way to recover it.  The second link is to share with colleagues and
friends.  With it anyone can read your document but not
edit it.

Documents are automatically saved as you edit.


More info: \\xlink{Getting the most out of Zipdocs}{kn886-dd906}  • \\xlink{About MiniLaTeX}{qw172-kk223}  •
\\xlink{About XMarkdown}{nr402-bm985}

\\image{https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQRF0zeCqrYUxEmZXRq_IdQtrqlYyAWZ627og&usqp=CAU}
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
