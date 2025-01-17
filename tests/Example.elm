module Example exposing (..)

--- (SearchConfig(..), search)

import APITypes exposing (Datum, Term(..))
import Expect exposing (Expectation)
import Parse exposing (parse)
import Search exposing (..)
import Sort exposing (Direction(..), SortParam(..), sort)
import Test exposing (..)
import Time exposing (Posix)


suite : Test
suite =
    describe "API"
        [ test "parser" <|
            \_ ->
                parse "foo -bar"
                    |> Expect.equal (Ok (Conjunction [ Word "foo", NotWord "bar" ]))
        , test "conjunctive search (2)" <|
            \_ ->
                search NotCaseSensitive "foo -bar" data
                    |> Expect.equal [ d3 ]
        , test "conjunctive search (1)" <|
            \_ ->
                search NotCaseSensitive "foo bar" data
                    |> Expect.equal [ d2 ]
        , test "conjunctive search (0)" <|
            \_ ->
                search NotCaseSensitive "foo" data
                    |> Expect.equal [ d2, d3 ]
        , test "date search (0)" <|
            \_ ->
                search NotCaseSensitive "@before:9/1/2021" [ d1, d2, d3, d4, d5 ]
                    |> Expect.equal [ d1, d2, d3 ]
        , test "date search (1)" <|
            \_ ->
                search NotCaseSensitive "@after:9/1/2021" [ d1, d2, d3, d4, d5 ]
                    |> Expect.equal [ d3, d4, d5 ]
        , test "case sensitive conjunctive search (0)" <|
            \_ ->
                search CaseSensitive "Foo" data
                    |> Expect.equal []
        , test "sort (1)" <|
            \_ ->
                sort (Alpha Increasing) [ d2, d2b, d3 ]
                    |> Expect.equal [ d2, d3, d2b ]
        , test "sort (d)" <|
            \_ ->
                sort (Alpha Decreasing) [ d2, d2b, d3 ]
                    |> Expect.equal (List.reverse [ d2, d3, d2b ])
        , test "sort date, ascending" <|
            \_ ->
                sort (DateTime Increasing) [ d3, d4, d5, d1, d2 ]
                    |> Expect.equal [ d1, d2, d3, d4, d5 ]
        , test "sort date, descending" <|
            \_ ->
                sort (DateTime Decreasing) [ d3, d4, d5, d1, d2 ]
                    |> Expect.equal (List.reverse [ d1, d2, d3, d4, d5 ])
        , test "posixGTE (1)" <|
            \_ ->
                posixGTE august july
                    |> Expect.equal True
        , test "posixGTE (2)" <|
            \_ ->
                posixGTE july august
                    |> Expect.equal False
        , test "posixLTE (1)" <|
            \_ ->
                posixLTE august july
                    |> Expect.equal False
        , test "posixLTE (2)" <|
            \_ ->
                posixLTE july august
                    |> Expect.equal True
        , test "posixLTEForDatum (1)" <|
            \_ ->
                posixLTEForDatum augustDatum june
                    |> Expect.equal False
        , test "posixLTEForDatum (2)" <|
            \_ ->
                posixLTEForDatum juneDatum august
                    |> Expect.equal True
        , test "posixGTEForDatum (1)" <|
            \_ ->
                posixGTEForDatum augustDatum june
                    |> Expect.equal True
        , test "posixGTEForData (2)" <|
            \_ ->
                posixGTEForDatum juneDatum august
                    |> Expect.equal False
        , test "searchWithTerm (1)" <|
            \_ ->
                searchWithTerm CaseSensitive beforeJuly_ [ juneDatum ]
                    |> Expect.equal [ { content = "JUNE", dateTime = Time.millisToPosix 1622591999000 } ]
        , test "searchWithTerm (2)" <|
            \_ ->
                searchWithTerm CaseSensitive afterJuly_ [ juneDatum ]
                    |> Expect.equal []
        , test "searchWithTerm (3)" <|
            \_ ->
                searchWithTerm CaseSensitive (Conjunction [ Word "foo", Word "bar" ]) data
                    |> Expect.equal [ d2 ]
        , test "search (1)" <|
            \_ ->
                search CaseSensitive "@before:7/1/2021" [ juneDatum ]
                    |> Expect.equal [ { content = "JUNE", dateTime = Time.millisToPosix 1622591999000 } ]
        , test "search (2)" <|
            \_ ->
                search CaseSensitive "@after:7/1/2021" [ juneDatum ]
                    |> Expect.equal []
        , test "colors (1)" <|
            \_ ->
                search CaseSensitive "@before:9/1/2021" colors
                    |> List.length
                    |> Expect.equal 4
        , test "colors (2)" <|
            \_ ->
                search CaseSensitive "@after:9/1/2021" colors
                    |> List.length
                    |> Expect.equal 3
        , test "colors (3)" <|
            \_ ->
                search CaseSensitive "@range:7/1/2021:9/1/2021" colors
                    |> List.length
                    |> Expect.equal 3
        ]


d1 =
    { content = "alpha beta ", dateTime = june }


d2 =
    { content = "alpha foo bar xx yy", dateTime = july }


d2b =
    { content = "gamma xx yy", dateTime = august }


d3 =
    { content = "beta foo beta Alpha xx yy", dateTime = september }


d4 =
    { content = "bar yada", dateTime = october }


d5 =
    { content = "doo yada", dateTime = november }


beforeJuly_ =
    BeforeDateTime (Time.millisToPosix 1625183999000)


afterJuly_ =
    AfterDateTime (Time.millisToPosix 1625183999000)


juneDatum =
    { content = "JUNE", dateTime = june }


julyDatum =
    { content = "JULY", dateTime = july }


augustDatum =
    { content = "AUGUST", dateTime = august }


june =
    Time.millisToPosix 1622591999000


july =
    Time.millisToPosix 1625183999000


august =
    Time.millisToPosix 1627862399000


september =
    Time.millisToPosix 1630540799000


october =
    Time.millisToPosix 1633132799000


november =
    Time.millisToPosix 1635811199000


data =
    [ d1, d2, d3, d4, d5 ]


data1 =
    [ d3 ]



-- COLORS


colors =
    [ c1, c2, c3, c4, c5, c6 ]


c1 =
    { content = "alizarin yellow", dateTime = june }


c2 =
    { content = "brown umber", dateTime = july }


c3 =
    { content = "yellow ochre", dateTime = august }


c4 =
    { content = "pthalo blue", dateTime = september }


c5 =
    { content = "french yellow", dateTime = october }


c6 =
    { content = "alizarin crimson, cadmium purple", dateTime = november }
