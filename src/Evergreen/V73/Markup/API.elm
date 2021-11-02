module Evergreen.V73.Markup.API exposing (..)

import Evergreen.V73.Block.Accumulator
import Evergreen.V73.Block.Block


type alias ParseData =
    { ast : List Evergreen.V73.Block.Block.Block
    , accumulator : Evergreen.V73.Block.Accumulator.Accumulator
    }
