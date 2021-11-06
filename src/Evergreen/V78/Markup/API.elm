module Evergreen.V78.Markup.API exposing (..)

import Evergreen.V78.Block.Accumulator
import Evergreen.V78.Block.Block


type alias ParseData =
    { ast : List Evergreen.V78.Block.Block.Block
    , accumulator : Evergreen.V78.Block.Accumulator.Accumulator
    }
