module Evergreen.V89.Block.Accumulator exposing (..)

import Evergreen.V89.LaTeX.MathMacro
import Evergreen.V89.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V89.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V89.Markup.Vector.Vector
    , theoremIndex : Evergreen.V89.Markup.Vector.Vector
    , equationIndex : Evergreen.V89.Markup.Vector.Vector
    }
