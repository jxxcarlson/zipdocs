module Evergreen.V74.Block.Accumulator exposing (..)

import Evergreen.V74.LaTeX.MathMacro
import Evergreen.V74.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V74.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V74.Markup.Vector.Vector
    }
