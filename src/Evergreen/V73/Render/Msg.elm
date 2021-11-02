module Evergreen.V73.Render.Msg exposing (..)

import Evergreen.V73.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V73.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
