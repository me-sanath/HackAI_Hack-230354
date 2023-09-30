from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
import requests

class TemperatureView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        latitude = request.data.get("latitude")
        longitude=request.data.get("longitude")
        if latitude and longitude:
            api_url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
            response = requests.get(api_url)
            temperature = response.json().get('current_weather').get('temperature')
            return Response({'temperature': temperature})
        else:
            return Response({'result':'failed','reason':'no latitude and/or longitude recieved'})
