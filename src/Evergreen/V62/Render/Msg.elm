module Evergreen.V62.Render.Msg exposing (..)

import Evergreen.V62.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V62.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
