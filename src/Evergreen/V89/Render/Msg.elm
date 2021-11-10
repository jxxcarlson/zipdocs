module Evergreen.V89.Render.Msg exposing (..)

import Evergreen.V89.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V89.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
