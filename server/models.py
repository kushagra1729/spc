from django.db import models

# Create your models here.

class DB_File(models.Model):
    bytes = models.TextField()
    filename = models.CharField(max_length=255)
    mimetype = models.CharField(max_length=50)
    username = models.CharField(max_length=150)

class Document(models.Model):
	description = models.CharField(max_length = 255, blank = True)
	base_folder = models.CharField(max_length = 255, blank = True)
	docfile = models.FileField(upload_to='server.DB_File/bytes/filename/mimetype')
	username = models.CharField(max_length=150)

class Folder(models.Model):
	base_folder = models.CharField(max_length = 255, blank = True)
	name = models.CharField(max_length = 255, blank = True)
	username = models.CharField(max_length=150)

class Reg(models.Model):
    username = models.CharField(max_length = 255, blank = False)
    password = models.CharField(max_length = 255, blank = False)
