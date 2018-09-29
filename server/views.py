from django.shortcuts import render_to_response,redirect,render
from django.template import RequestContext
from django.http import HttpResponseRedirect
# from django.core.urlresolvers import reverse

from server.models import Document
from server.forms import DocumentForm


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
    # documents = Document.objects.all()

    # Render list page with the documents and the form
    return render(request, 'upload/upload.html',
        {'form': form})