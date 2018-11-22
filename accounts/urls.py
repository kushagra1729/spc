from django.conf.urls import url,include
from django.contrib.auth import views as auth_views
from . import views

app_name = 'accounts'

urlpatterns = [
    url(r'^signup/$', views.signup, name='signup'),
    url(r'^login/$', auth_views.LoginView.as_view(template_name='accounts/login.html'), name='login'),
    url(r'^change-password/$',
        auth_views.PasswordChangeView.as_view(template_name='accounts/passchange.html',
                                              success_url='done/'),name='pass_change'),
    url(r'^change-password/done/$',
        auth_views.LoginView.as_view(template_name='accounts/login.html'),
        name='password_change_done'
        ),
    url('', include('django.contrib.auth.urls')),
]
