module Evergreen.V76.Block.Accumulator exposing (..)

import Evergreen.V76.LaTeX.MathMacro
import Evergreen.V76.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V76.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V76.Markup.Vector.Vector
    }
