from django.shortcuts import render
from hangman.backend import Hangman
from django.template import loader
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json



wordChoices = ["apple", "banana", "orange", "grape"]
hangman = Hangman("banana")


def index(request):
    template = loader.get_template('hangman/main.html')
    return render(request, 'hangman/main.html')

@csrf_exempt
def guess(request):
    """
    {
	"guessChar": "A"
    }

    {
    "guessChar" : "A",
   "indices": [],
   "isGameOver": false,
   "hasWon": false
   }
    """

    data = json.loads(request.body)
    guessChar = data['guessChar']
    indices = hangman.guessChar(guessChar)

    if len(indices) == 0:
        hangman.loseLife()
    else: 
        hangman.removeChars(guessChar)
    
    isGameOver = hangman.isGameOver()
    
    hasWon = False
    if (len(hangman.word) == 0):
        hasWon = True

    guessResponse = {
        'guessChar' : guessChar,
        'indices' : indices,
        'isGameOver' : isGameOver,
        'hasWon' : hasWon
    }
    return JsonResponse(guessResponse)

@csrf_exempt
def start(request):
    
    startResponse = {
        'shouldStart' : True,
        'wordCount' : len(hangman.word),
        'startLives' : 10
    }

    return JsonResponse(startResponse)    


"""



Look up how to generate a CSRF token and what exactly Cross Site Request Forgery is.
"""