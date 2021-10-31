module Evergreen.V60.Render.Msg exposing (..)

import Evergreen.V60.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V60.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
