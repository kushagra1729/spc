# project
from . import views
from .compat import url


urlpatterns = [
    url(r'^download/', views.get_file, {'add_attachment_headers': True},
        name='file_storage.download_file'),
    url(r'^get/', views.get_file, {'add_attachment_headers': False},
        name='file_storage.get_file')
]
