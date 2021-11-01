module Evergreen.V64.Render.Msg exposing (..)

import Evergreen.V64.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V64.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
