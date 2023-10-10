from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone
# Create your models here.

class WeatherPref(models.Model):
    user = models.ForeignKey(User,on_delete=models.CASCADE,blank=True,null=True)
    minumumTemperature = models.IntegerField(blank=True,null=True)
    maximumTemperature = models.IntegerField(blank=True,null=True)
    setLocation = models.JSONField(("locationPref"),default=list,blank=True,null=True)
    toNofify = models.BooleanField(default=False,verbose_name="Notify User")
    token = models.CharField(max_length=255, null = True,blank=True)
    lastNotified = models.DateTimeField(default = timezone.now,null=True, blank=True)