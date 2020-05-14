module Page.Index exposing (..)

import Bootstrap.Badge as Badge
import Bootstrap.Button as Button
import Bootstrap.Card as Card
import Bootstrap.Card.Block as CardBlock
import Bootstrap.Form.Input as Input
import Bootstrap.Grid as Grid
import Bootstrap.Navbar as Navbar
import Bootstrap.Utilities.Flex as Flex
import Bootstrap.Utilities.Spacing as Spacing
import Extra.Extra as Extra
import Extra.Html as EH
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (attribute, autoplay, id, loop, placeholder, property, src, style, width)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import RemoteData as RD exposing (RemoteData(..), WebData)
import Request.Gif as RequestGif exposing (Gif, GifQuery)
import Set exposing (Set)
import View.WebData exposing (viewWebData)


type Msg
    = NoOp
    | LoadedMetadata
    | LoadGif
    | LoadedGif (WebData (List Gif))
    | NextPage
    | PrevPage
    | ToggleTag String
    | ClearTags


type alias Model =
    { flags : Flags
    , page : Int
    , selectedTags : Set String
    , gifs : WebData (List Gif)
    }


extractGifQuery : Model -> GifQuery
extractGifQuery model =
    let
        tags =
            if Set.isEmpty model.selectedTags then
                Nothing

            else
                Just <| Set.toList model.selectedTags
    in
    { page = model.page
    , tags = tags
    }


defaultGifWidth : Int
defaultGifWidth =
    300


resetPage : Model -> Model
resetPage model =
    { model | page = 0 }


getGifs : Model -> ( Model, Cmd Msg )
getGifs model =
    let
        cmd =
            RequestGif.getGifs model.flags (extractGifQuery model) LoadedGif

        updatedModel =
            { model | gifs = Loading }
    in
    ( updatedModel, cmd )


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        model =
            { flags = flags
            , page = 0
            , selectedTags = Set.empty
            , gifs = Loading
            }
    in
    model |> getGifs


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        LoadedMetadata ->
            ( model, Cmd.none )

        LoadGif ->
            ( model, Cmd.none )

        LoadedGif resp ->
            ( { model | gifs = resp }, Cmd.none )

        PrevPage ->
            let
                prevPage =
                    max 0 (model.page - 1)
            in
            { model | page = prevPage } |> getGifs

        NextPage ->
            { model | page = model.page + 1 } |> getGifs

        ToggleTag tag ->
            let
                selectedTags =
                    if Set.member tag model.selectedTags then
                        Set.remove tag model.selectedTags

                    else
                        Set.insert tag model.selectedTags
            in
            { model | selectedTags = selectedTags }
                |> resetPage
                |> getGifs

        ClearTags ->
            if Set.isEmpty model.selectedTags then
                ( model, Cmd.none )

            else
                { model | selectedTags = Set.empty }
                    |> resetPage
                    |> getGifs


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ viewGifs model
        , div [ Flex.row, Flex.block ]
            [ viewPaginationButtons model
            , Button.button [ Button.attrs [ Spacing.ml5 ], Button.warning, Button.onClick ClearTags ] [ text "Clear Selected Tags" ]
            ]
        ]


viewGifs : Model -> Html Msg
viewGifs model =
    let
        v gifs =
            gifs
                |> List.map (viewGif model.flags model)
                |> div [ Flex.block, Flex.row, Flex.wrap, Flex.alignItemsCenter, Flex.justifyBetween ]
    in
    viewWebData v model.gifs


viewGif : Flags -> Model -> Gif -> Html Msg
viewGif flags model gif =
    Card.config []
        |> Card.header [] []
        |> Card.block []
            [ CardBlock.custom <|
                video
                    [ id gif.id, width defaultGifWidth, autoplay True, loop True ]
                    [ source [ src <| flags.bucket ++ gif.id ++ ".mp4" ] [] ]
            ]
        |> Card.footer []
            [ viewTags model gif.tags
            ]
        |> Card.view


viewTags : Model -> List String -> Html Msg
viewTags model tags =
    let
        viewTag tag =
            Set.member tag model.selectedTags
                |> Extra.ternary Badge.badgePrimary Badge.badgeSecondary
                |> (\b -> b [ style "cursor" "pointer", onClick (ToggleTag tag) ] [ text tag ])
    in
    tags
        |> List.map viewTag
        |> div []


viewPaginationButtons : Model -> Html Msg
viewPaginationButtons { page } =
    div [ Flex.row ]
        [ Button.button [ Button.attrs [ Spacing.ml2 ], Button.primary, Button.onClick PrevPage ] [ text "Prev Page" ]
        , span [ Spacing.ml2 ] [ text <| "Page: " ++ String.fromInt page ]
        , Button.button [ Button.attrs [ Spacing.ml2 ], Button.primary, Button.onClick NextPage ] [ text "Next Page" ]
        ]
