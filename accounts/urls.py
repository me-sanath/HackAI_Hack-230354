from django.urls import path
from . import views

urlpatterns = [
    path('register/', views.register, name='user-register'),
    path('login/', views.UserLoginView.as_view(), name='user-login'),
    # Add more URLs for other account management actions
]