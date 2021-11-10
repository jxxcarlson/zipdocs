module Evergreen.V91.Markup.API exposing (..)

import Evergreen.V91.Block.Accumulator
import Evergreen.V91.Block.Block


type alias ParseData =
    { ast : List Evergreen.V91.Block.Block.Block
    , accumulator : Evergreen.V91.Block.Accumulator.Accumulator
    }
