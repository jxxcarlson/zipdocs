module Expression.State exposing (State)

import Either exposing (Either)
import Expression.AST exposing (Expr)
import Expression.Token exposing (Token)
import Lang.Token.Common


type alias State =
    { sourceText : String
    , scanPointer : Int
    , tokenStack : Expression.Token.TokenStack
    , end : Int
    , stack : List (Either Token Expr)
    , committed : List Expr
    , count : Int
    }
