module AddToWord exposing (..)

import Array exposing (Array)

-- [1, 3], "A", ArrayOf[- - - - - -]
addToWord : List Int -> Char -> Array Char -> List Char
addToWord indices guessChar acc = 
    case indices of
        [] ->
            Array.toList acc
            
        x :: xs ->
            addToWord xs guessChar (Array.set x guessChar acc) 


    