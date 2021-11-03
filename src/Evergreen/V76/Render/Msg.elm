module Evergreen.V76.Render.Msg exposing (..)

import Evergreen.V76.Markup.Meta


type MarkupMsg
    = SendMeta Evergreen.V76.Markup.Meta.ExpressionMeta
    | GetPublicDocument String
