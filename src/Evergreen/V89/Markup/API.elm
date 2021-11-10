module Evergreen.V89.Markup.API exposing (..)

import Evergreen.V89.Block.Accumulator
import Evergreen.V89.Block.Block


type alias ParseData =
    { ast : List Evergreen.V89.Block.Block.Block
    , accumulator : Evergreen.V89.Block.Accumulator.Accumulator
    }
