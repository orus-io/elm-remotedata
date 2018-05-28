module RemoteDataTest exposing (all)

import Expect
import RemoteData exposing (..)
import Test exposing (describe, test)


all : Test
all =
    describe "The RemoteData module"
        [ mapTests
        , andMapTests
        , mapBothTests
        , prismTests
        , fromListTests
        , fromMaybeTests
        ]


mapTests : Test
mapTests =
    let
        check ( label, input, output ) =
            test label <|
                \_ ->
                    map ((*) 3) input
                        |> Expect.equal output
    in
    describe "map" <|
        List.map check
            [ ( "Success", Success 2, Success 6 )
            , ( "NotAsked", NotAsked, NotAsked )
            , ( "Loading", Loading, Loading )
            , ( "Failure", Failure "error", Failure "error" )
            ]


mapBothTests : Test
mapBothTests =
    let
        check ( label, input, output ) =
            test label <|
                \_ ->
                    mapBoth ((*) 3) ((++) "error") input
                        |> Expect.equal output
    in
    describe "mapBoth" <|
        List.map check
            [ ( "Success", Success 2, Success 6 )
            , ( "NotAsked", NotAsked, NotAsked )
            , ( "Loading", Loading, Loading )
            , ( "Failure", Failure "", Failure "error" )
            ]


prismTests : Test
prismTests =
    test "webDataPrism" <|
        \_ ->
            prism.getOption (prism.reverseGet 5)
                |> Expect.equal (Just 5)


andMapTests : Test
andMapTests =
    let
        check ( label, output, expected ) =
            test label <|
                \_ ->
                    Expect.equal expected output
    in
    describe "andMap" <|
        List.map check
            [ ( "Success case"
              , andMap (Success 5) (Success ((*) 2))
              , Success 10
              )
            , ( "Failure case 1"
              , andMap (Failure "nope") Loading
              , Failure "nope"
              )
            , ( "Failure case 2"
              , andMap Loading (Failure "nope")
              , Failure "nope"
              )
            ]


fromListTests : Test
fromListTests =
    let
        check ( label, output, expected ) =
            test label <|
                \_ ->
                    Expect.equal expected output
    in
    describe "fromList" <|
        List.map check
            [ ( "Success from empty", fromList [], Success [] )
            , ( "Success from singleton"
              , fromList [ Success 1 ]
              , Success [ 1 ]
              )
            , ( "Success from list with many values"
              , fromList [ Success 1, Success 2 ]
              , Success [ 1, 2 ]
              )
            , ( "Loading from list with Loading and no Failure 1"
              , fromList [ NotAsked, Loading ]
              , Loading
              )
            , ( "Loading from list with Loading and no Failure 2"
              , fromList [ Success 1, Loading ]
              , Loading
              )
            , ( "Failure from list with Failure1"
              , fromList [ Success 1, Loading, Failure "nope" ]
              , Failure "nope"
              )
            , ( "Failure from list with Failure 2"
              , fromList [ Success 1, Failure "nah", Success 2, Failure "nope" ]
              , Failure "nah"
              )
            ]


fromMaybeTests : Test
fromMaybeTests =
    let
        check ( label, output, expected ) =
            test label <|
                \_ ->
                    Expect.equal expected output
    in
    describe "fromMaybe" <|
        List.map check
            [ ( "Just to Success 1", fromMaybe "Should be 1" (Just 1), Success 1 )
            , ( "Nothing to Failure 1", fromMaybe "Should be 1" Nothing, Failure "Should be 1" )
            , ( "Just to Success 2", fromMaybe "fail" (Just [ 1, 2, 3 ]), Success [ 1, 2, 3 ] )
            , ( "Nothing to Failure 2", fromMaybe "fail" Nothing, Failure "fail" )
            ]
