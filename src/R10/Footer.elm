module R10.Footer exposing (view)

{-| Generic footer.

Be aware that this component depends on the `Header` component for historical and logical reasons.

@docs view

-}

import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import R10.Header


{-| -}
view : R10.Header.Model -> R10.Header.ViewArgs msg route -> Element msg
view model args =
    column
        [ width fill
        , Background.color <| rgb 0.3 0.3 0.3
        , Font.color <| rgb 0.8 0.8 0.8
        , paddingXY 0 60
        , Font.size 16
        , spacing 50
        ]
    <|
        [ el
            [ moveRight 14
            , width (fill |> maximum model.maxWidth)
            , centerX
            ]
          <|
            args.logoOnDark
        , row
            [ width (fill |> maximum model.maxWidth)
            , centerX
            ]
            [ column [ width fill, alignTop ]
                args.extraContent
            , column [ width fill, alignTop ] <|
                []
                    ++ R10.Header.languageMenu model args
                    ++ R10.Header.menuSeparator
                    ++ [ case model.session of
                            R10.Header.SessionNotRequired ->
                                none

                            R10.Header.SessionNotRequested ->
                                none

                            R10.Header.SessionFetching ->
                                none

                            R10.Header.SessionSuccess _ ->
                                map args.msgMapper <| R10.Header.logoutLink model args

                            R10.Header.SessionError _ ->
                                map args.msgMapper <| R10.Header.loginLink model args
                       ]
            ]
        , el [ alignBottom, centerX, Font.size 14 ] <| text "© Rakuten, Inc."
        ]
