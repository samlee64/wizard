module Request.Gif exposing (..)

import Flags exposing (Flags)
import Http
import HttpBuilder as HB
import Json.Decode as Decode exposing (Decoder, field, list, map, map2, string)
import Json.Encode as Encode
import RemoteData as RD exposing (WebData)
import Url.Builder as UrlBuilder


type alias GifQuery =
    { page : Int
    , tags : Maybe (List String)
    , id : Maybe String
    }


type alias Gif =
    { id : String
    }


gifDecoder : Decoder Gif
gifDecoder =
    map Gif
        (field "id" string)



--    (field "tags" (list string))


getGifs : Flags -> GifQuery -> (WebData (List Gif) -> msg) -> Cmd msg
getGifs flags query msg =
    let
        tags =
            query.tags
                |> Maybe.map (\t -> Encode.encode 0 (Encode.list Encode.string t))
                |> Maybe.map ((++) "&tags=")
                |> Maybe.withDefault ""

        id =
            query.id
                |> Maybe.map (\i -> Encode.encode 0 (Encode.string i))
                |> Maybe.map ((++) "&id=")
                |> Maybe.withDefault ""

        queryString =
            String.fromInt query.page
                |> (++) "?page="
                |> (++) id
                |> (++) tags

        path =
            "gifs" ++ queryString
    in
    UrlBuilder.crossOrigin flags.api [ path ] []
        |> HB.get
        |> HB.withExpect (Http.expectJson (RD.fromResult >> msg) (list gifDecoder))
        |> HB.request
