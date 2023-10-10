from django.contrib import admin
from django.contrib.auth.admin import UserAdmin
from django.contrib.auth.models import User
from weather.models import WeatherPref

# Define your inline class
class WeatherPrefInline(admin.StackedInline):
    model = WeatherPref
    extra = 0

# Extend the default UserAdmin class
class CustomUserAdmin(UserAdmin):
    list_display = ('email', 'first_name', 'last_name', 'is_active', 'is_staff')
    list_filter = ('is_active', 'is_staff')
    search_fields = ('email', 'first_name', 'last_name')
    ordering = ('email',)
    inlines = [WeatherPrefInline]

# Register the extended UserAdmin class
admin.site.unregister(User)  # Unregister the default User admin
admin.site.register(User, CustomUserAdmin)  # Register your custom User admin


