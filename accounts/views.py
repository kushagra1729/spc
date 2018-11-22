from django.contrib.auth import logout, login, authenticate
from django.shortcuts import render, redirect
from django.contrib.auth.forms import UserCreationForm

def passchangedone(request):
    logout(request)
    return render(request, 'accounts/passchangedone.html')

def signup(request):
    if request.method == 'POST':
        form = UserCreationForm(request.POST)
        if form.is_valid():
            form.save()
            username = form.cleaned_data.get('username')
            raw_password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=raw_password)
            login(request, user)
            return redirect('/accounts/login')
    else:
        form = UserCreationForm()
    return render(request, 'accounts/signup.html', {'form': form})