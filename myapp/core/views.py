from django.shortcuts import render
from django.http import HttpResponse


#def home(request):
    #return HttpResponse('<h1>Welcome to the Django.</h1>')


def home(request):
    return render(request, 'index.html')
