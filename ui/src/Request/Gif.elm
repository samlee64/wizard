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
    }


type alias Gif =
    { id : String
    , tags : List String
    }


gifDecoder : Decoder Gif
gifDecoder =
    map2 Gif
        (field "id" string)
        (field "tags" (list string))



--    (field "tags" (list string))


getGifs : Flags -> GifQuery -> (WebData (List Gif) -> msg) -> Cmd msg
getGifs flags query msg =
    let
        sam =
            query.tags
                |> Maybe.map (\tas -> tas |> List.map (\ta -> Encode.encode 0 (Encode.string ta)))

        tags =
            query.tags
                |> Maybe.map (List.map (\t -> "\"" ++ t ++ "\""))
                |> Maybe.map (List.intersperse ",")
                |> Maybe.map (List.foldl (++) "")
                |> Maybe.map (\tagsString -> "&tags=[" ++ tagsString ++ "]")
                |> Maybe.withDefault ""

        queryString =
            "?page=" ++ String.fromInt query.page ++ tags

        path =
            "gifs" ++ queryString
    in
    UrlBuilder.crossOrigin flags.api [ path ] []
        |> HB.get
        |> HB.withExpect (Http.expectJson (RD.fromResult >> msg) (list gifDecoder))
        |> HB.request
