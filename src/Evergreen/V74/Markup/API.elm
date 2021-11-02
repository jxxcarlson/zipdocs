module Evergreen.V74.Markup.API exposing (..)

import Evergreen.V74.Block.Accumulator
import Evergreen.V74.Block.Block


type alias ParseData =
    { ast : List Evergreen.V74.Block.Block.Block
    , accumulator : Evergreen.V74.Block.Accumulator.Accumulator
    }
