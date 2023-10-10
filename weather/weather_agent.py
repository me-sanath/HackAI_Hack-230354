from uagents import Agent, Context, Model
import httpx
import asyncio
from firebase_admin import credentials, messaging
import firebase_admin



temperature_alert_agent = Agent(name="temperature_alert")
# Location
latitude = 12.971599
longitude = 77.594566
# Variables for threshold temps
upper_threshold = 20  
lower_threshold = 15 


class TemperatureData(Model):
    temperature: float

async def alert_user(message):
    print(message)

async def send_notification_to_token(fcm_token, title, body):
    # Initialize Firebase Admin SDK with your service account credentials
    

    # Create a message
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=fcm_token,
    )

    # Send the message
    try:
        response = await messaging.send(message)
        print("Notification sent successfully:", response)
    except Exception as e:
        print("Error sending notification:", str(e))

async def fetch_temperature(ctx: Context):
    api_url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current_weather=true"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(api_url)
            data = response.json()
            temperature = data.get("current_weather", {}).get("temperature", None)
            if temperature is not None:
                temperature_data = TemperatureData(temperature=temperature)
                await alert_on_temperature(temperature_data, ctx)

    except Exception as e:
        ctx.logger.error(f"Error fetching temperature data: {str(e)}")

async def alert_on_temperature(temperature_data: TemperatureData, ctx: Context):
    temperature = temperature_data.temperature
    if temperature > upper_threshold:
        await alert_user(f"Temperature Alert: High Temperature Detected : {temperature}°C")
    elif temperature < lower_threshold:
        await alert_user(f"Temperature Alert: Low Temperature Detected : {temperature}°C")

@temperature_alert_agent.on_interval(period=5)  
async def check_temperature(ctx: Context):
    await fetch_temperature(ctx)

if __name__ == "__main__":
    cred = credentials.Certificate('path/to/your/serviceAccountKey.json')
    firebase_admin.initialize_app(cred)
    temperature_alert_agent.run()

