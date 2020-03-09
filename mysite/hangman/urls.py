from django.urls import path

from . import views


urlpatterns = [
    # /hangman/
    path('', views.index, name='index'),
    # /hangman/guess/
    path('guess', views.guess, name='guess'),
    # /hangman/start
    path('start', views.start, name='start'),
]