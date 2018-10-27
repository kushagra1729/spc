from django.shortcuts import render_to_response,redirect,render
from django.template import RequestContext
from django.http import HttpResponseRedirect
# from django.core.urlresolvers import reverse

from server.models import Document,Reg,Folder,DB_File
from server.forms import DocumentForm,RegistrationForm,FolderForm
from django.contrib.auth.decorators import login_required
from django.views.decorators.csrf import csrf_exempt
import os

from django.conf import settings
from django.http import HttpResponse

from rest_framework.views import APIView
from rest_framework.decorators import api_view
from rest_framework.response import Response
from django.http import JsonResponse
# from rest_framework import Response

@csrf_exempt
@login_required
def list(request,folder_path):
    # Handle file upload
    print("LISTING")
    if request.method == 'POST':
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            curruser = form.save(commit=False)
            curruser.username=request.user
            form.save()

            # Redirect to the document list after POST
            # CHANGE THIS LATER
            return redirect('upload/'+folder_path) 
    else:
        form = DocumentForm() # A empty, unbound form

    # Load documents for the list page
    # documents=[]
    # documents = Document.objects.all()
    documents=Document.objects.filter(base_folder=folder_path).filter(username=request.user)
    folders=Folder.objects.filter(base_folder=folder_path).filter(username=request.user)
    # folders=Folder.objects.filter(username=request.user)
    # documents = Document.objects.all().filter(username=request.user)
    # f903cdfd461b869ba2289356252f45ec5f67e616

    # Render list page with the documents and the form
    return render(request, 'upload/upload.html',
        {'form': form,'documents' : documents, 'folders':folders, 'dir':folder_path})

@csrf_exempt
@login_required
def add_folder(request):
    # Handle file upload
    if request.method == 'POST':
        form = FolderForm(request.POST)
        if form.is_valid():
            # newdoc = Document(docfile = request.FILES['docfile'])
            curruser = form.save(commit=False)
            curruser.username=request.user
            # form.save()

            form.save()

            # Redirect to the document list after POST
            return redirect('add_folder') 
    else:
        form = FolderForm() # A empty, unbound form

    # Load documents for the list page
    documents = Folder.objects.all()

    # Render list page with the documents and the form
    return render(request, 'folder_add/folder_add.html',
        {'form': form,'documents' : documents})

@login_required
def download(request, path):
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        with open(file_path, 'rb') as fh:
            response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
            response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
            return response
    raise Http404

@login_required
def api_file_list(request, folder_path):
    documents=Document.objects.filter(base_folder=folder_path).filter(username=request.user)
    folders=Folder.objects.filter(base_folder=folder_path).filter(username=request.user)
    fold_arr=[]
    file_arr=[]
    for folder in folders:
        fold_arr.append(folder.name)
    for file in documents:
        file_arr.append(file.docfile.name)
    return JsonResponse({'folders':fold_arr, 'files':file_arr},safe=False)

@login_required
@api_view(['POST'])
@csrf_exempt
def remove_folder(request):
    # print("HELLO")
    name=request.data['name']
    folder_path=request.data['base_folder']
    Folder.objects.filter(base_folder=folder_path).filter(username=request.user).filter(name=name).delete()
    return JsonResponse({},safe=False)

@login_required
@api_view(['POST'])
@csrf_exempt
def remove_file(request):
    # print("HELLO")
    name="server.DB_File/bytes/filename/mimetype/"+request.data['name']
    print(name)
    folder_path=request.data['base_folder']
    arr=Document.objects.filter(base_folder=folder_path).filter(username=request.user) #.filter(name=name).delete()
    DB_File.objects.filter(filename=name).delete()
    for document in arr:
        print(document.docfile.name)
        if(document.docfile.name == name):
            print("DELETING")
            document.delete() 
    return JsonResponse({},safe=False)


def register(request):
    if request.method == 'POST':
        form = RegistrationForm(request.POST)
        if form.is_valid():
            # newdoc = Document(docfile = request.FILES['docfile'])
            form.save()
            print(request.POST['username'])
            os.mkdir(settings.MEDIA_ROOT+'/'+request.POST['username'])

            # Redirect to the document list after POST
            return redirect('upload') 
    else:
        form = RegistrationForm() # A empty, unbound form

    # Load documents for the list page
    

    # Render list page with the documents and the form
    return render(request, 'register/register.html',
        {'form_reg': form})
