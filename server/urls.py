from django.urls import path
from django.conf.urls import url
from django.conf.urls.static import static
from django.conf import settings

from . import views

urlpatterns = [url(r'upload/(?P<folder_path>.*)$',views.list, name='upload'),
				url(r'^server/media/(?P<path>.+)$',views.download,name='download'),
				    url(r'^register/$',views.register,name='register'),
				 url(r'^add_folder/$',views.add_folder,name='add_folder')	
				]

if settings.DEBUG:
	urlpatterns += static(settings.MEDIA_URL, document_root = settings.MEDIA_ROOT)
