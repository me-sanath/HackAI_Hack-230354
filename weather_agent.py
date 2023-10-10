from uagents import Agent, Context, Model
import httpx
import asyncio
from firebase_admin import credentials, messaging
import firebase_admin
import random
import time
import json

temperature_alert_agent = Agent(name="temperature_alert")

# Routes
base_url = "http://127.0.0.1:8000/"
server_url = base_url+"weather/getalldata/"
update_notify = base_url+"weather/onNotify/"

# Auth Tokens
AUTH_TOKEN = "590c2387fcfbc53561d048173780a837016a081f"

class TemperatureData(Model):
    temperature: float

class UserData(Model):
    min_temperature: float
    max_temperature: float
    fcm_token: str
    identifier: str
    to_notify: bool
    last_notified: float # Timestamp
    latitude: float
    longitude: float

async def alert_user(message):
    print(message)

async def build_notification(temperature_type):
    notification = "Check todays weather on cli-Mate App"
    
    if temperature_type == "HIGH":
        notifications = [
            "Temperature is too high. Stay cool and hydrated!",
            "Hot day ahead. Don't forget to wear sunscreen!",
            "High Temp alert! Stay indoors and keep hydrated.",
        ]
    elif temperature_type == "LOW":
        notifications = [
            "Temperature is low. Bundle up and stay warm!",
            "Cold weather warning. Dress warmly before going out.",
            "Chilly day ahead. Grab a hot drink to stay cozy!",
        ]
    else:
        return notification

    notification = random.choice(notifications)
    return notification

async def switch_notification(identifier,switch,ctx:Context):
    try:
        async with httpx.AsyncClient() as client:
            header = {"Authorization":"Token "+identifier}
            response = await client.post(update_notify,headers=header,json={"notification":switch})
            if response.status_code == 200:
                return True
            else:
                ctx.logger.error(f"Switch : Response Failed :{response.text}")
                return False
    except:
        ctx.logger.error("Failed to switch")
        return False

async def send_notification_to_token(fcm_token, title, body,ctx: Context):
    # Create a message
    ctx.logger.info("Sent notification for user")
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=fcm_token,
    )
    # Send the message
    try:
        response = messaging.send(message)
        print("Notification sent successfully:", response)
        return {"result": True,"data":response}
    except Exception as e:
        print("Error sending notification:", str(e))
        return {"result": False,"data":response}

async def fetch_temperature(userData: UserData ,ctx: Context):
    api_url = f"https://api.open-meteo.com/v1/forecast?latitude={userData.latitude}&longitude={userData.longitude}&current_weather=true"
    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(api_url)
            data = response.json()
            temperature = data.get("current_weather", {}).get("temperature", None)
            ctx.logger.info("Fetch Success")
            return {"result":True,"data":temperature}

    except Exception as e:
        ctx.logger.error(f"Error fetching temperature data: {str(e)}")
        return {"result":False,"data":"Failed to fetch temperature"}

async def alert_on_temperature(userData: UserData, ctx: Context):
    temperature = await fetch_temperature(userData=userData,ctx=ctx)
    if temperature["result"]:
        if temperature["data"] > userData.max_temperature:
            notification_body = await build_notification("HIGH")
            await switch_notification(userData.identifier,False,ctx)
            await send_notification_to_token(fcm_token=userData.fcm_token,title="High Temperature Alert",body=notification_body,ctx=ctx)
        elif temperature["data"] < userData.min_temperature:
            notification_body = await build_notification("LOW")
            await switch_notification(userData.identifier,False,ctx)
            await send_notification_to_token(fcm_token=userData.fcm_token,title="Low Temperature Alert",body=notification_body,ctx=ctx)

async def loadUser(ctx: Context):
    header = {"Authorization": "Token " + AUTH_TOKEN}
    userList = []
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(server_url, headers=header)
            if response.status_code == 200:  # Check if the response status is OK
                try:
                    json_res = response.json()  
                    if json_res["result"]:
                        allUserData = json_res["users"]
                        for user in allUserData:
                            objUser = UserData(identifier=user["identifier"], max_temperature=user["max_temp"], min_temperature=user["min_temp"], fcm_token=user["user_token"], to_notify=user["notification"], last_notified=user["last_notified"], latitude=user["latitude"], longitude=user["longitude"])
                            userList.append(objUser)
                        return userList
                    else:
                        ctx.logger.error("Server error")
                        return False
                except Exception as json_error:
                    ctx.logger.error(f"Error parsing JSON response: {json_error}")
                    return False
            else:
                ctx.logger.error(f"Server returned status code: {response.status_code}")
                return False
    except Exception as e:
        ctx.logger.error(f"Exception occurred: {e}")


@temperature_alert_agent.on_interval(period=30)  
async def check_temperature(ctx: Context):
    userObjectsList = await loadUser(ctx=ctx)
    timenow = time.time()
    notifyCheckList = []
    for user in userObjectsList:
        if user.to_notify:
            notifyCheckList.append(user)
        elif  (timenow - user.last_notified) > 3600:
            res = await switch_notification(user.identifier,switch=True,ctx=ctx)
            notifyCheckList.append(user) if res else None
        else:
            ctx.logger.info("No User to Notify")
    for notify in notifyCheckList:
        await alert_on_temperature(notify,ctx)

if __name__ == "__main__":
    cred = credentials.Certificate('climate-c11a3-firebase-adminsdk-dulsm-468c8ba2a9.json')
    firebase_admin.initialize_app(cred)
    temperature_alert_agent.run()

