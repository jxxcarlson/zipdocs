module Evergreen.V63.Render.Msg exposing (..)

import Evergreen.V63.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V63.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
