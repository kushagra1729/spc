from django.conf.urls import url,include
from django.contrib.auth import views as auth_views
from . import views

app_name = 'accounts'

urlpatterns = [
    url(r'^login/$', auth_views.LoginView.as_view(template_name='registration/login.html'), name='login'),
    url(r'^change-password/$',
        auth_views.PasswordChangeView.as_view(template_name='registration/passchange.html',
                                              success_url='done/'),name='pass_change'),
    url(r'^change-password/done/$',
        views.passchangedone,
        name='password_change_done'
        ),
    url('', include('django.contrib.auth.urls')),
]
