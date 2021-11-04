module Evergreen.V77.Markup.API exposing (..)

import Evergreen.V77.Block.Accumulator
import Evergreen.V77.Block.Block


type alias ParseData =
    { ast : List Evergreen.V77.Block.Block.Block
    , accumulator : Evergreen.V77.Block.Accumulator.Accumulator
    }
