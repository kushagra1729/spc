from django import forms
from server.models import Document,Reg

class DocumentForm(forms.ModelForm):
    class Meta:
    	model= Document
    	fields=('description', 'docfile',)

class RegistrationForm(forms.ModelForm):
	class Meta:
		model=Reg
		fields=('username','password',)