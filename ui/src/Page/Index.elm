module Page.Index exposing (..)

import Bootstrap.Card as Card
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
view _ =
    div []
        [ text "SIKE its a SPIKE"

        --, video [ autoplay True, loop True ] [ source [ src "http://wizard-fullstack-test.s3-us-west-2.amazonaws.com/gifs/UnxdQO00tFl7jEqMPa.mp4" ] [] ]
        ]


viewGifs : Model -> Html Msg
viewGifs model =
    model.gifs
        |> RD.map (List.map viewGif)
        |> RD.withDefault [ text "error" ]
        |> div []


viewGif : Gif -> Html Msg
viewGif gif =
    Card.config []
        |> Card.header [] []
        |> Card.block [] []
        |> Card.view
