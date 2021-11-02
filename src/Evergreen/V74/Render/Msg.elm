module Evergreen.V74.Render.Msg exposing (..)

import Evergreen.V74.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V74.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
