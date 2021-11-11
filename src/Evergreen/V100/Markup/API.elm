module Evergreen.V100.Markup.API exposing (..)

import Evergreen.V100.Block.Accumulator
import Evergreen.V100.Block.Block


type alias ParseData =
    { ast : List Evergreen.V100.Block.Block.Block
    , accumulator : Evergreen.V100.Block.Accumulator.Accumulator
    }
