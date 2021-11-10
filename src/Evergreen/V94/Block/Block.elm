module Evergreen.V94.Block.Block exposing (..)

import Evergreen.V94.Markup.Meta


type ExprM
    = TextM String Evergreen.V94.Markup.Meta.ExpressionMeta
    | VerbatimM String String Evergreen.V94.Markup.Meta.ExpressionMeta
    | ArgM (List ExprM) Evergreen.V94.Markup.Meta.ExpressionMeta
    | ExprM String (List ExprM) Evergreen.V94.Markup.Meta.ExpressionMeta
    | ErrorM String


type BlockStatus
    = BlockUnfinished String
    | MismatchedTags String String
    | BlockUnimplemented
    | BlockComplete


type alias Meta =
    { begin : Int
    , end : Int
    , indent : Int
    , id : String
    , status : BlockStatus
    , label : String
    }


type Block
    = Paragraph (List ExprM) Meta
    | VerbatimBlock String (List String) Evergreen.V94.Markup.Meta.ExpressionMeta Meta
    | Block String (List Block) Meta
    | BError String
