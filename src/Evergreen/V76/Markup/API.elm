module Evergreen.V76.Markup.API exposing (..)

import Evergreen.V76.Block.Accumulator
import Evergreen.V76.Block.Block


type alias ParseData =
    { ast : List Evergreen.V76.Block.Block.Block
    , accumulator : Evergreen.V76.Block.Accumulator.Accumulator
    }
