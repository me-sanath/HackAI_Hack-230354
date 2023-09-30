from uagents import Agent, Context, Model
import httpx
import asyncio

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
    temperature_alert_agent.run()
