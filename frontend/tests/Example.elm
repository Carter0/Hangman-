module Example exposing (..)

import Expect
import Test exposing (..)
import AddToWord

import Array exposing (Array)


suite : Test
suite =
    describe "AddToWord"
        [ 
        test "Banana B guess"
            (\_ -> Expect.equal ['b', '-', '-', '-', '-', '-'] 
                (AddToWord.addToWord [0]'b' (Array.fromList ['-', '-', '-', '-', '-', '-'])))
        , 
        test "Banana A Guess"
            (\_ -> Expect.equal ['-', 'a', '-', 'a', '-', 'a'] 
                (AddToWord.addToWord [1, 3, 5] 'a' (Array.fromList ['-', '-', '-', '-', '-', '-'])))
        , 
        test "Adding onto a Word"
            (\_ -> Expect.equal ['b', 'a', '-', 'a', '-', 'a'] 
                (AddToWord.addToWord [0] 'b' (Array.fromList ['-', 'a', '-', 'a', '-', 'a'])))
        , 
        test "No Match"
            (\_ -> Expect.equal ['b', 'a', '-', 'a', '-', 'a'] 
                (AddToWord.addToWord [] 'z' (Array.fromList ['b', 'a', '-', 'a', '-', 'a'])))
         ]