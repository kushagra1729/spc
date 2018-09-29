from django.shortcuts import render_to_response,redirect,render
from django.template import RequestContext
from django.http import HttpResponseRedirect
# from django.core.urlresolvers import reverse

from server.models import Document,Reg
from server.forms import DocumentForm,RegistrationForm
import os

from django.conf import settings
from django.http import HttpResponse


def list(request):
    # Handle file upload
    if request.method == 'POST':
        form = DocumentForm(request.POST, request.FILES)
        if form.is_valid():
            # newdoc = Document(docfile = request.FILES['docfile'])
            form.save()

            # Redirect to the document list after POST
            return redirect('upload') 
    else:
        form = DocumentForm() # A empty, unbound form

    # Load documents for the list page
    documents = Document.objects.all()

    # Render list page with the documents and the form
    return render(request, 'upload/upload.html',
        {'form': form,'documents' : documents})


def download(request, path):
    file_path = os.path.join(settings.MEDIA_ROOT, path)
    if os.path.exists(file_path):
        with open(file_path, 'rb') as fh:
            response = HttpResponse(fh.read(), content_type="application/vnd.ms-excel")
            response['Content-Disposition'] = 'inline; filename=' + os.path.basename(file_path)
            return response
    raise Http404

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
