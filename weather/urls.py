from django.urls import path
from .views import dashboardView,setPrefView,forecastView

urlpatterns = [
    path('dashboard/', dashboardView.as_view(), name='current-time'),
    path('setpref/',setPrefView.as_view(),name = 'set-temps'),
    path('forecast/',forecastView.as_view(),name = 'forecast')
]
