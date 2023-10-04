from django.db import models
from accounts.models import CustomUser
# Create your models here.

class WeatherPref(models.Model):
    user = models.ForeignKey(CustomUser,on_delete=models.CASCADE,blank=True,null=True)
    minumumTemperature = models.IntegerField(blank=True,null=True)
    maximumTemperature = models.IntegerField(blank=True,null=True)
    setLocation = models.JSONField(("locationPref"),default=list,blank=True,null=True)
    toNofify = models.BooleanField(default=False,verbose_name="Notify User")