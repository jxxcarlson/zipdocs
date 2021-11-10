module Evergreen.V94.Render.Msg exposing (..)

import Evergreen.V94.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V94.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
