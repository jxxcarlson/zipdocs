module Evergreen.V91.Render.Msg exposing (..)

import Evergreen.V91.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V91.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
