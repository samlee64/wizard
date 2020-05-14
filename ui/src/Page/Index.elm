module Page.Index exposing (..)

import Html exposing (..)
import Html.Attributes exposing (autoplay, loop, src)


type Msg
    = NoOp
    | LoadedMetadata
    | LoadGif
    | LoadedGif
    | HandleSearchInput


type alias Model =
    { page : Int
    , pageSize : Int
    , searchInput : String
    }


init : ( Model, Cmd Msg )
init =
    ( { page = 0
      , pageSize = 50
      , searchInput = ""
      }
    , Cmd.none
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

        LoadedGif ->
            ( model, Cmd.none )

        HandleSearchInput ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


view : Model -> Html Msg
view _ =
    div []
        [ text "SIKE its a SPIKE"
        , video [ autoplay True, loop True ] [ source [ src "http://wizard-fullstack-test.s3-us-west-2.amazonaws.com/gifs/UnxdQO00tFl7jEqMPa.mp4" ] [] ]
        ]
