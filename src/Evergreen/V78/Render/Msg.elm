module Evergreen.V78.Render.Msg exposing (..)

import Evergreen.V78.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V78.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
