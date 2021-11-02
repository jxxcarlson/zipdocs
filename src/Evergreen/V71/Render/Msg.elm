module Evergreen.V71.Render.Msg exposing (..)

import Evergreen.V71.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V71.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
