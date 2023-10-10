from django.urls import path
from .views import dashboardView,setPrefView,forecastView,getAllUserData,onNotification

urlpatterns = [
    path('dashboard/', dashboardView.as_view(), name='current-time'),
    path('setpref/',setPrefView.as_view(),name = 'set-temps'),
    path('forecast/',forecastView.as_view(),name = 'forecast'),
    path('getalldata/',getAllUserData.as_view(),name='for-uagents'),
    path('onNotify/',onNotification.as_view(),name='notify')
]
