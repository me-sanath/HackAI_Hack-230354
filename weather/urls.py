from django.urls import path
from .views import TemperatureView

urlpatterns = [
    path('current-temp/', TemperatureView.as_view(), name='current-time'),
    # Add more URL patterns for other views if needed
]
