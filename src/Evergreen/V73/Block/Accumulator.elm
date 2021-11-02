module Evergreen.V73.Block.Accumulator exposing (..)

import Evergreen.V73.LaTeX.MathMacro
import Evergreen.V73.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V73.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V73.Markup.Vector.Vector
    }
