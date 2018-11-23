from django.contrib import admin
from .models import DB_File, Document, Folder, Reg

admin.site.register(DB_File)
admin.site.register(Document)
admin.site.register(Folder)
admin.site.register(Reg)

# Register your models here.
