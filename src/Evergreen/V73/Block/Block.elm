module Evergreen.V73.Block.Block exposing (..)

import Evergreen.V73.Markup.Meta


type ExprM
    = TextM String Evergreen.V73.Markup.Meta.ExpressionMeta
    | VerbatimM String String Evergreen.V73.Markup.Meta.ExpressionMeta
    | ArgM (List ExprM) Evergreen.V73.Markup.Meta.ExpressionMeta
    | ExprM String (List ExprM) Evergreen.V73.Markup.Meta.ExpressionMeta
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
    }


type Block
    = Paragraph (List ExprM) Meta
    | VerbatimBlock String (List String) Evergreen.V73.Markup.Meta.ExpressionMeta Meta
    | Block String (List Block) Meta
    | BError String
