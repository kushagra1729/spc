from django.urls import path
from django.conf.urls import url
from django.conf.urls.static import static
from django.conf import settings

from . import views

urlpatterns = [path('upload',views.list, name='upload'),
				url(r'^server/media/(?P<path>.+)$',views.download,name='download')	
					]

if settings.DEBUG:
	urlpatterns += static(settings.MEDIA_URL, document_root = settings.MEDIA_ROOT)
