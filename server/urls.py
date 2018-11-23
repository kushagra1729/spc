from django.urls import path
from django.conf.urls import url
from django.conf.urls.static import static
from django.conf import settings

from . import views

urlpatterns = [url(r'upload/(?P<folder_path>.*)$',views.list, name='upload'),
				url(r'^server/media/(?P<path>.+)$',views.download,name='download'),
				 url(r'^register/$',views.register,name='register'),
				 # url(r'^add_folder/$',views.add_folder,name='add_folder'),
				 url(r'^api/files/(?P<folder_path>.*)$', views.api_file_list),
				 url(r'^api/remove_folder/$', views.remove_folder),
				 url(r'^api/remove_file/$', views.remove_file),
				 url(r'^api/upload_folder/$', views.api_upload_folder),
				 url(r'^api/upload_file/$', views.api_upload_file),
				 url(r'^lock/$',views.lock),
				 url(r'^unlock/$',views.unlock),
				 ]

if settings.DEBUG:
	urlpatterns += static(settings.MEDIA_URL, document_root = settings.MEDIA_ROOT)
