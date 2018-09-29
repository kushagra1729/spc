from django.db import models

# Create your models here.

class Document(models.Model):
	description = models.CharField(max_length = 255, blank = True)
	docfile = models.FileField(upload_to='documents/')

class Reg(models.Model):
	username = models.CharField(max_length = 255, blank = False)
	password = models.CharField(max_length = 255, blank = False)