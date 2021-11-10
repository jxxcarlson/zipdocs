module Evergreen.V89.Markup.Meta exposing (..)


type alias ExpressionMeta =
    { id : String
    , loc :
        { begin :
            { row : Int
            , col : Int
            }
        , end :
            { row : Int
            , col : Int
            }
        }
    , label : String
    }
