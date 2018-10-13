from django import forms
from server.models import Document,Reg,Folder

class DocumentForm(forms.ModelForm):
    class Meta:
    	model= Document
    	fields=('description', 'base_folder', 'docfile',)

class FolderForm(forms.ModelForm):
    class Meta:
    	model= Folder
    	fields=('base_folder', 'name',)

class RegistrationForm(forms.ModelForm):
	class Meta:
		model=Reg
		fields=('username','password',)