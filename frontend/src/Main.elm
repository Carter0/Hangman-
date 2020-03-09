module Main exposing (..)

import Browser
import Html exposing (Attribute, Html, button, div, input, text)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (type_, placeholder)
import Http
import Array exposing (Array)
import Json.Decode as Decode
import Json.Encode as Encode


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL
-- Note, this is here but it just renders things, logic is in the backend.
{-
   The charcount represents the number of chars in the string. When the user starts the game the server
   will tell elm how many chars are in the word. Elm will then add that many dashes to the dashboard.

   The wordSoFar will actually never hold the total word to guess for. Just all the char's the
   player has completely guessed. Before then it will be filled with dashes after the user starts the game

   hasStarted indicates whether the game has started or not. The player will start the game by clicking a play button which
   then makes the server respond with data.

   Lives is just for the view. The actual lives data is held on the server.

-}


type alias Model =
    { charCount : Int
    , wordSoFar : List Char
    , hasStarted : Bool
    , lives : Int
    , lost : Bool
    , won : Bool
    , failure : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { charCount = 0
      , wordSoFar = []
      , hasStarted = False
      , lives = 0
      , lost = False
      , won = False
      , failure = False
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = Guess String
    | Start
    | GotStartMessage (Result Http.Error StartResponse)
    | GotMessage (Result Http.Error Response)


type alias StartResponse =
    { shouldStart : Bool
    , wordCount : Int
    , startLives : Int
    }


{-
    An example of a response

    {
    "guessChar" : "A",
   "indices": [1, 3],
   "isGameOver": false,
   "hasWon": false
   }
-}

type alias Response =
    { guessChar : String
    , indices : List Int
    , isGameOver : Bool
    , hasWon : Bool
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Start ->
            ( model, startJSONSend )

        Guess guess ->
            ( model, guessJSONSend guess )

        GotStartMessage startResult ->
            case startResult of
                Ok response ->
                    ( { model | hasStarted = True, lives = response.startLives
                    , wordSoFar = List.repeat response.wordCount '-' }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model | failure = True }
                    , Cmd.none
                    )

        GotMessage hangmanResult ->
            case hangmanResult of
                Ok response ->
                    ( guessResponseLogic response model, Cmd.none )

                Err _ ->
                    ( { model | failure = True }
                    , Cmd.none
                    )

guessResponseLogic : Response -> Model -> Model
guessResponseLogic response model = 
    case (response.isGameOver, response.hasWon) of 
        (True, True) -> 
            { model | won = True }
        (True, False) -> 
            { model | lost = True }
        (_, _) -> 
            if List.isEmpty response.indices then 
                { model | lives = model.lives - 1 }
            else 
                addToWord response.indices response.guessChar (Array.fromList model.wordSoFar) model

-- [1, 3], "A", ArrayOf[- - - - - -]
addToWord : List Int -> String -> Array Char -> Model -> Model
addToWord indices guessString acc model = 
    let
        guessChar = 
            guessString
                |> String.toList
                |> List.head
                |> Maybe.withDefault '%' {-- TODO problem is this happens on backspace, input bad, need button--}
    in
    case indices of
        [] ->
            { model | wordSoFar = Array.toList acc }
            
        x :: xs ->
            addToWord xs guessString (Array.set x guessChar acc) model
    

-- HANDLING JSON


startJSONSend : Cmd Msg
startJSONSend =
    Http.post
        { url = "http://127.0.0.1:8000/hangman/start"
        , body = Http.jsonBody (Encode.string "start")
        , expect = Http.expectJson GotStartMessage startResponseJSON
        }


startResponseJSON : Decode.Decoder StartResponse
startResponseJSON =
    Decode.map3 StartResponse
        (Decode.field "shouldStart" Decode.bool)
        (Decode.field "wordCount" Decode.int)
        (Decode.field "startLives" Decode.int)


guessJSONSend : String -> Cmd Msg
guessJSONSend guess =
    Http.post
        { url = "http://127.0.0.1:8000/hangman/guess"
        , body = Http.jsonBody (guessJSON guess)
        , expect = Http.expectJson GotMessage inputJSON
        }


guessJSON : String -> Encode.Value
guessJSON guess =
    Encode.object
        [ ( "guessChar", Encode.string guess ) ]


inputJSON : Decode.Decoder Response
inputJSON =
    Decode.map4 Response
        (Decode.field "guessChar" Decode.string)
        (Decode.field "indices" (Decode.list Decode.int))
        (Decode.field "isGameOver" Decode.bool)
        (Decode.field "hasWon" Decode.bool)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ if model.failure == True then
            text "Something went wrong :("

          else if model.hasStarted == False then
            showStart

          else
            showGame model
        ]


showStart : Html Msg
showStart =
    div []
        [ div [] [ text "Start the game!" ]
        , button [ onClick Start ] [ text "Play" ]
        ]


showGame : Model -> Html Msg
showGame model =
    div []
        [ div [] [ text "Hangman!" ]
        , div [] [ text (String.fromList model.wordSoFar) ]
        , div [] [ text (String.fromInt model.lives) ]
        , input [type_ "text", placeholder "Guess", onInput Guess ] []
        ]
