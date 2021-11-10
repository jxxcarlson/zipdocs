module Evergreen.V91.Block.Accumulator exposing (..)

import Evergreen.V91.LaTeX.MathMacro
import Evergreen.V91.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V91.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V91.Markup.Vector.Vector
    , theoremIndex : Evergreen.V91.Markup.Vector.Vector
    , equationIndex : Evergreen.V91.Markup.Vector.Vector
    }
