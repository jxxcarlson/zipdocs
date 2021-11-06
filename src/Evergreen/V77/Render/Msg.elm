module Evergreen.V77.Render.Msg exposing (..)

import Evergreen.V77.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V77.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
