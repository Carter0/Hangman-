#!/usr/local/bin/python3
import random

class Hangman: 

    
    def __init__(self, word):
        self.word = word
        self.lives = 10

    # Will return the index/'s of the char in the word
    # Returns an empty list if no char's found
    def guessChar(self, char):
        indices = []
        location = -1
        while True:
            location = self.word.find(char, location+1)
            indices.append(location)
            if location == -1:
                indices.pop() 
                break
        return indices
    
    def removeChars(self, char):
        self.word = self.word.replace(char, '')

    def loseLife(self):
        self.lives -= 1

    def isGameOver(self):
        if self.lives == 0: 
            return True
        else:
            return False

        