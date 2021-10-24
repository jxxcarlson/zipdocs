module View.Input exposing
    ( enterPrivateId
    , passwordInput
    , searchDocsInput
    , usernameInput
    )

import Element as E exposing (Element, px)
import Element.Font as Font
import Element.Input as Input
import Types exposing (FrontendModel, FrontendMsg(..))


enterPrivateId displayText =
    inputFieldTemplate (E.px 200) "Private ID" InputAuthorId displayText


inputFieldTemplate : E.Length -> String -> (String -> msg) -> String -> Element msg
inputFieldTemplate width_ default msg text =
    Input.text [ E.moveUp 5, Font.size 16, E.height (px 33), E.width width_ ]
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        }


passwordTemplate : E.Length -> String -> (String -> msg) -> String -> Element msg
passwordTemplate width_ default msg text =
    Input.currentPassword [ E.moveUp 5, Font.size 16, E.height (px 33), E.width width_ ]
        { onChange = msg
        , text = text
        , label = Input.labelHidden default
        , placeholder = Just <| Input.placeholder [ E.moveUp 5 ] (E.text default)
        , show = False
        }


searchDocsInput : FrontendModel -> Element FrontendMsg
searchDocsInput model =
    inputFieldTemplate E.fill "Filter/fetch (:me, :public, :h, ...)" InputSearchKey model.inputSearchKey


usernameInput model =
    inputFieldTemplate (E.px 120) "Username" InputUsername model.inputUsername


passwordInput model =
    passwordTemplate (E.px 120) "Password" InputPassword model.inputPassword
