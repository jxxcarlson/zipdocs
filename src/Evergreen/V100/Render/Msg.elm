module Evergreen.V100.Render.Msg exposing (..)

import Evergreen.V100.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V100.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
