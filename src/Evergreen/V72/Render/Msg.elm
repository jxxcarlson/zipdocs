module Evergreen.V72.Render.Msg exposing (..)

import Evergreen.V72.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V72.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
