from django import forms
from server.models import Document

class DocumentForm(forms.ModelForm):
    class Meta:
    	model= Document
    	fields=('description', 'docfile',)