module Evergreen.V77.Block.Accumulator exposing (..)

import Evergreen.V77.LaTeX.MathMacro
import Evergreen.V77.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V77.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V77.Markup.Vector.Vector
    }
