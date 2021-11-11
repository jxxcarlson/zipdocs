module Evergreen.V100.Block.Accumulator exposing (..)

import Dict
import Evergreen.V100.LaTeX.MathMacro
import Evergreen.V100.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V100.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V100.Markup.Vector.Vector
    , theoremIndex : Evergreen.V100.Markup.Vector.Vector
    , equationIndex : Evergreen.V100.Markup.Vector.Vector
    , crossReferences : Dict.Dict String String
    }
