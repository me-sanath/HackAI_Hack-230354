from django.contrib import admin
from accounts.models import CustomUser
from weather.models import WeatherPref
# Register your models here.


class WeatherPrefInline(admin.StackedInline):
    model = WeatherPref
    extra = 0 

@admin.register(CustomUser)
class UserAdmin(admin.ModelAdmin):
    list_display = ('email', 'first_name', 'last_name', 'is_active', 'is_staff')
    list_filter = ('is_active', 'is_staff')
    search_fields = ('email', 'first_name', 'last_name')
    ordering = ('email',)
    inlines = [WeatherPrefInline]

