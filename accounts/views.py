from django.contrib.auth import logout
from django.shortcuts import render


def passchangedone(request):
    logout(request)
    return render(request, 'registration/passchangedone.html')
