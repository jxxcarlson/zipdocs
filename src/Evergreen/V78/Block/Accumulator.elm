module Evergreen.V78.Block.Accumulator exposing (..)

import Evergreen.V78.LaTeX.MathMacro
import Evergreen.V78.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V78.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V78.Markup.Vector.Vector
    }
