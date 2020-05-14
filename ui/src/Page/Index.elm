module Page.Index exposing (..)

import Bootstrap.Card as Card
import Bootstrap.Card.Block as CardBlock
import Bootstrap.Utilities.Flex as Flex
import Extra.Html as EH
import Flags exposing (Flags)
import Html exposing (..)
import Html.Attributes exposing (autoplay, loop, src)
import RemoteData as RD exposing (RemoteData(..), WebData)
import Request.Gif exposing (Gif, GifQuery, getGifs)


type Msg
    = NoOp
    | LoadedMetadata
    | LoadGif
    | LoadedGif (WebData (List Gif))
    | HandleSearchInput


type alias Model =
    { flags : Flags
    , page : Int
    , searchInput : String
    , gifs : WebData (List Gif)
    }


defaultGifQuery : GifQuery
defaultGifQuery =
    { page = 0, tags = Nothing, id = Nothing }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { flags = flags
      , page = 0
      , searchInput = ""
      , gifs = Loading
      }
    , getGifs flags defaultGifQuery LoadedGif
    )


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

        HandleSearchInput ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view model =
    div []
        [ text "SIKE its a SPIKE"
        , viewGifs model
        ]


viewGifs : Model -> Html Msg
viewGifs model =
    model.gifs
        |> RD.map (List.map (viewGif model.flags))
        |> RD.withDefault [ text "error" ]
        |> div [ Flex.block, Flex.row ]


viewGif : Flags -> Gif -> Html Msg
viewGif flags gif =
    Card.config []
        |> Card.header [] [ text gif.id ]
        |> Card.block []
            [ CardBlock.custom <|
                div []
                    [ video
                        [ autoplay True, loop True ]
                        [ source [ src <| flags.bucket ++ gif.id ++ ".mp4" ] [] ]
                    ]
            ]
        |> Card.view
