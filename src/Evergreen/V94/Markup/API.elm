module Evergreen.V94.Markup.API exposing (..)

import Evergreen.V94.Block.Accumulator
import Evergreen.V94.Block.Block


type alias ParseData =
    { ast : List Evergreen.V94.Block.Block.Block
    , accumulator : Evergreen.V94.Block.Accumulator.Accumulator
    }
