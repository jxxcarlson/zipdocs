module Evergreen.V94.Block.Accumulator exposing (..)

import Dict
import Evergreen.V94.LaTeX.MathMacro
import Evergreen.V94.Markup.Vector


type alias Accumulator =
    { macroDict : Evergreen.V94.LaTeX.MathMacro.MathMacroDict
    , sectionIndex : Evergreen.V94.Markup.Vector.Vector
    , theoremIndex : Evergreen.V94.Markup.Vector.Vector
    , equationIndex : Evergreen.V94.Markup.Vector.Vector
    , crossReferences : Dict.Dict String String
    }
