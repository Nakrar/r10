module R10.Table.Paginator exposing (getPaginationStateRecord_, paginationButtonDisableAll_, paginationButtonEnableAll_, paginationButtonEnableOther_, paginationButtonNextFetch_, paginationButtonPrevFetch_, updatePaginationState_, view)

import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Html exposing (Html)
import Html.Attributes
import Html.Events
import R10.Form
import Svg
import R10.Table.Config exposing (PaginationConfig)
import R10.Table.Msg
import R10.Table.State exposing (PaginationButtonState(..), PaginationState(..), PaginationStateRecord)
import R10.Table.Svg exposing (arrowNext, arrowPrev)


buttonStyle : List (Attribute msg)
buttonStyle =
    [ padding 9
    , alignRight
    , Border.rounded 4
    , alpha 0.7
    , width <| px 40
    , height <| px 40
    , htmlAttribute <| Html.Attributes.style "transition" "all 0.2s ease-out"
    ]


intToOption : Int -> Html msg
intToOption v =
    Html.option [ Html.Attributes.value (String.fromInt v) ] [ Html.text (String.fromInt v) ]


numberOfRowsSelector : PaginationConfig -> PaginationStateRecord -> Element R10.Table.Msg.Msg
numberOfRowsSelector paginationConfig state =
    row
        [ alignRight
        , spacing 8
        ]
        [ text "Rows per page"
        , el [ moveDown 1 ] <|
            html <|
                Html.select
                    [ Html.Events.onInput <|
                        String.toInt
                            >> Maybe.withDefault 0
                            >> R10.Table.Msg.PaginatorLengthOption
                    , Html.Attributes.value <| String.fromInt state.length
                    ]
                <|
                    List.map intToOption paginationConfig.lengthOptions
        ]


viewPaginationButton : R10.Table.Msg.Msg -> (String -> Int -> Svg.Svg R10.Table.Msg.Msg) -> PaginationButtonState -> Element R10.Table.Msg.Msg
viewPaginationButton msg icon state =
    el
        (buttonStyle
            ++ (case state of
                    PaginationButtonEnabled ->
                        [ Events.onClick <| msg
                        , pointer
                        , mouseOver [ alpha 1, Background.color <| rgba 0 0 0 0.035 ]
                        ]

                    _ ->
                        [ alpha 0.3 ]
               )
        )
        (html <| icon "black" 22)


view : R10.Form.Palette -> PaginationConfig -> PaginationState -> Element R10.Table.Msg.Msg
view _ paginationConfig paginationState =
    case paginationState of
        -- todo refactor it so pagination would work with default state initially,
        -- creating custom state on pagination change
        Pagination state ->
            row
                [ width fill
                , height <| px 56
                , spacing 32
                , paddingXY 16 0
                ]
                [ numberOfRowsSelector paginationConfig state
                , row [ spacing 16 ]
                    [ viewPaginationButton R10.Table.Msg.PaginatorPrevPage arrowPrev state.prevButtonState
                    , viewPaginationButton R10.Table.Msg.PaginatorNextPage arrowNext state.nextButtonState
                    ]
                ]

        NoPagination ->
            none


updatePaginationState_ : R10.Table.State.PaginationStateRecord -> R10.Table.State.State -> R10.Table.State.State
updatePaginationState_ paginationStateRecord state =
    { state | pagination = R10.Table.State.Pagination paginationStateRecord }


paginationButtonNextFetch_ : R10.Table.State.State -> R10.Table.State.State
paginationButtonNextFetch_ state =
    case getPaginationStateRecord_ state of
        Just paginationStateRecord ->
            { state
                | pagination =
                    R10.Table.State.Pagination
                        { paginationStateRecord
                            | nextButtonState = PaginationButtonLoading
                            , prevButtonState =
                                if paginationStateRecord.prevButtonState == PaginationButtonLoading then
                                    PaginationButtonOtherLoading

                                else
                                    paginationStateRecord.prevButtonState
                        }
            }

        Nothing ->
            state


paginationButtonPrevFetch_ : R10.Table.State.State -> R10.Table.State.State
paginationButtonPrevFetch_ state =
    case getPaginationStateRecord_ state of
        Just paginationStateRecord ->
            { state
                | pagination =
                    R10.Table.State.Pagination
                        { paginationStateRecord
                            | nextButtonState =
                                if paginationStateRecord.nextButtonState == PaginationButtonLoading then
                                    PaginationButtonOtherLoading

                                else
                                    paginationStateRecord.nextButtonState
                            , prevButtonState = PaginationButtonLoading
                        }
            }

        Nothing ->
            state


paginationButtonEnableAll_ : R10.Table.State.State -> R10.Table.State.State
paginationButtonEnableAll_ state =
    case getPaginationStateRecord_ state of
        Just paginationStateRecord ->
            { state
                | pagination =
                    R10.Table.State.Pagination
                        { paginationStateRecord
                            | nextButtonState = PaginationButtonEnabled
                            , prevButtonState = PaginationButtonEnabled
                        }
            }

        Nothing ->
            state


paginationButtonDisableAll_ : R10.Table.State.State -> R10.Table.State.State
paginationButtonDisableAll_ state =
    case getPaginationStateRecord_ state of
        Just paginationStateRecord ->
            { state
                | pagination =
                    R10.Table.State.Pagination
                        { paginationStateRecord
                            | nextButtonState = PaginationButtonDisabled
                            , prevButtonState = PaginationButtonDisabled
                        }
            }

        Nothing ->
            state


paginationButtonEnableOther_ : R10.Table.State.State -> R10.Table.State.State
paginationButtonEnableOther_ state =
    case getPaginationStateRecord_ state of
        Just paginationStateRecord ->
            let
                nextState : PaginationButtonState -> PaginationButtonState
                nextState current =
                    case current of
                        PaginationButtonDisabled ->
                            PaginationButtonDisabled

                        PaginationButtonLoading ->
                            PaginationButtonDisabled

                        PaginationButtonOtherLoading ->
                            PaginationButtonEnabled

                        PaginationButtonEnabled ->
                            PaginationButtonEnabled
            in
            { state
                | pagination =
                    R10.Table.State.Pagination
                        { paginationStateRecord
                            | nextButtonState = nextState paginationStateRecord.nextButtonState
                            , prevButtonState = nextState paginationStateRecord.prevButtonState
                        }
            }

        Nothing ->
            state


getPaginationStateRecord_ : R10.Table.State.State -> Maybe R10.Table.State.PaginationStateRecord
getPaginationStateRecord_ state =
    case state.pagination of
        R10.Table.State.Pagination paginationState ->
            Just paginationState

        R10.Table.State.NoPagination ->
            Nothing
