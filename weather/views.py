from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from django.http import JsonResponse
from weather.models import WeatherPref
from rest_framework.authtoken.models import Token
from django.contrib.auth.models import User
from django.utils import timezone

import requests
import logging

class dataloger:
    def __init__(self):
        self.logger = logging.getLogger('Logger')
        self.logger.setLevel(logging.DEBUG)
        file_handler = logging.FileHandler("logs.log")
        file_handler.setLevel(logging.DEBUG)
        formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
        file_handler.setFormatter(formatter)

        self.logger.addHandler(file_handler)

    def info(self, message):
        self.logger.info(message)

    def error(self, message):
        self.logger.error(message)

    def warning(self, message):
        self.logger.warning(message)

# Initialize logger 
logger = dataloger()


routes = {
    "geocodeURL":"https://geocoding-api.open-meteo.com/v1/search?name=<location>&count=1&language=en&format=json"
}

def geocode(locationName):
    try:
        response = requests.get(routes["geocodeURL"].replace("<location>",str(locationName)))
        if response.status_code == 200:
            result = response.json().get("results")
            if result:
                returnData = {
                    "result": True,
                    "data":{
                        "geocode":{
                            "latitude":result[0].get("latitude"),
                            "longitude":result[0].get("longitude")
                        }
                    }
                }
            else:
                returnData = {
                    "result": False,
                    "data":{
                        "status":"LOC_ERR",
                        "message": "No location found"
                    }
                }
            return returnData
        else:
            response.raise_for_status()

    except Exception as error:
        logger.error(f"Geocoding : Unexpected Error : {str(error)}")
        return {"result": False, "data":{"status":"CRIC","message":str(error)}}
    

def weatherData(geocode):
    try:
        latitude = geocode.get("latitude")
        longitude= geocode.get("longitude")
        if latitude and longitude:
                api_url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&hourly=relativehumidity_2m&current_weather=true"
                response = requests.get(api_url)
                data = response.json()
                try:
                    current_time = data['current_weather']['time'][:-2]+"00"
                    humidity = data['hourly']['relativehumidity_2m'][data['hourly']['time'].index(current_time)]
                except:
                    humidity = None
                returnData = {
                    "temperature": data['current_weather']['temperature'],
                    "windspeed": data['current_weather']['windspeed'],
                    "humidity": humidity,
                    "weathercode":data['current_weather']['weathercode']
                }
                return {"result": True,"data":returnData}
    except Exception as e:
        print(str(e))
        return {"result": False,"data":{"status":"CRIC","message": str(e)}}
            

class dashboardView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        print(request.data)
        location = request.data.get("locationName",None)
        latitude = request.data.get("latitude",None)
        longitude  =request.data.get('longitude',None)
        user = request.user
        weatherpref = WeatherPref.objects.get_or_create(user=user)[0]
        if location is not None:
            response = geocode(locationName=location.strip())
        elif latitude is not None and longitude is not None:
            weatherpref.setLocation = [latitude,longitude]
            weatherpref.token = request.data.get("fc_token",weatherpref.token)
            response = {"result": True, "data": {"geocode": {"latitude": latitude, "longitude": longitude}}}
        else:
            return Response({'reason': 'no location data'}, status=400)

        if response["result"]:
            geocode_data = response["data"]["geocode"]
            weather_response = weatherData(geocode_data)
            
            if weather_response["result"]:
                print(weather_response["data"])
                weatherpref.save()
                return JsonResponse({"data": weather_response["data"]})
            else:
                return Response({'reason': weather_response["data"]["message"]}, status=422)
        else:
            return Response({'reason': response["data"]["message"]}, status=422)
        
        

class forecastView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self,request):
        location = request.data.get("locationName")
        latitude = request.data.get("latitude",None)
        longitude  =request.data.get('longitude',None)
        if location is not None:
            response = geocode(locationName=location)
        elif latitude is not None and longitude is not None:
            response = {"result": True, "data": {"geocode": {"latitude": latitude, "longitude": longitude}}}
        else:
            return Response({'reason': 'no location data'}, status=400)
        
        if response["result"]:
            latitude = response['data']['geocode']['latitude']
            longitude = response['data']['geocode']['longitude']     
            forecast_data = []
            api_url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&daily=weathercode,temperature_2m_max,temperature_2m_min&timezone=auto"
            response = requests.get(api_url)
            if response.status_code == 200:
                data = response.json()
                for i in range(len(data["daily"]["time"])):
                    forecast_entry = {
                        "min": data["daily"]["temperature_2m_min"][i],
                        "max": data["daily"]["temperature_2m_max"][i],
                        "weathercode": data["daily"]["weathercode"][i],
                        "date": data["daily"]["time"][i]
                    }
                    forecast_data.append(forecast_entry)
                return JsonResponse({"forecast": forecast_data})
            else:
                return Response(response.text,status=400)
        return Response({"reason":response["data"]["message"]},status=400)


class setPrefView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        min_temperature = request.data.get('min_temperature')
        max_temperature = request.data.get('max_temperature')
        fCMToken = request.data.get('fctoken')
        weather_pref = WeatherPref.objects.get_or_create(user=user)[0]  
        weather_pref.minumumTemperature = min_temperature
        weather_pref.maximumTemperature = max_temperature
        weather_pref.toNofify = True
        weather_pref.save()
        return Response({'message': 'Weather preferences updated successfully'})
    
class getAllUserData(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        user = request.user
        response = {"result":False,"users":[]}
        if user.is_superuser:
            all_users = User.objects.all()
            for user in all_users:
                if not user.is_staff:
                    weatherData = WeatherPref.objects.filter(user=user).first()
                    if weatherData:
                        if weatherData.minumumTemperature is not None:
                            try:
                                latitude = weatherData.setLocation[0]
                                longitude = weatherData.setLocation[1]
                            except:
                                latitude = None
                                longitude = None
                            notification = weatherData.toNofify
                            last_sent = weatherData.lastNotified
                            min_temp = weatherData.minumumTemperature
                            max_temp = weatherData.maximumTemperature
                            fc_token = weatherData.token
                            token = Token.objects.get_or_create(user=user)[0]
                            userData = {
                                "identifier":token.key,
                                "user_token": fc_token,
                                "latitude": latitude,
                                "longitude": longitude,
                                "notification": notification,
                                "last_notified": last_sent.timestamp() if last_sent is not None else None,
                                "min_temp": min_temp,
                                "max_temp":max_temp,
                            }
                            response["users"].append(userData)
            response["result"]= True
            return JsonResponse(response,status=200)
        else:
            return Response({"data":"Unauthorised"},status=403)
        
class onNotification(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, *args, **kwargs):
        notification = request.data.get("notification")     
        weather = WeatherPref.objects.filter(user = request.user).first()
        weather.toNofify = notification
        if notification == False:
            weather.lastNotified = timezone.now()
        weather.save()
        return Response("Success",200)