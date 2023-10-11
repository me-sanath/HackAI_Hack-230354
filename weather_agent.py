# Import necessary libraries and modules
from uagents import Agent, Context, Model
import httpx
import asyncio
from firebase_admin import credentials, messaging
import firebase_admin
import random
import time
import json

# Create a new agent named "temperature_alert"
temperature_alert_agent = Agent(name="temperature_alert")

# Define the base URLs and routes for the server communication
base_url = "http://3.110.85.253/" #Change to local one if running locally
server_url = base_url + "weather/getalldata/"
update_notify = base_url + "weather/onNotify/"

# Define the authentication token for server communication
# Obtain this token by sending postman request to http://your-server-address/api/login with jsonbody containing email and password for superuser created
AUTH_TOKEN = "0e65ba414e6e60e54225eafa12d6ed98c3943cbd" # Replace this token

# Create a data model for temperature data
class TemperatureData(Model):
    temperature: float


# Define a data model for user data
class UserData(Model):
    min_temperature: float
    max_temperature: float
    fcm_token: str
    identifier: str
    to_notify: bool
    last_notified: float  # Timestamp
    latitude: float
    longitude: float

# Define an asynchronous function to alert the user with a message
async def alert_user(message):
    print(message)

# Define an asynchronous function to build a notification based on temperature type
async def build_notification(temperature_type):
    notification = "Check today's weather on the cli-Mate App"
    
    # Determine the notification message based on the temperature type
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
        return notification  # Default notification if temperature_type is not recognized

    # Select a random notification message from the list
    notification = random.choice(notifications)
    return notification


# Asynchronous function to switch user notifications on or off
async def switch_notification(identifier, switch, ctx: Context):
    try:
        async with httpx.AsyncClient() as client:
            header = {"Authorization": "Token " + identifier}
            response = await client.post(update_notify, headers=header, json={"notification": switch})
            if response.status_code == 200:
                return True  # Switch successful
            else:
                ctx.logger.error(f"Switch: Response Failed: {response.text}")
                return False  # Switch failed
    except:
        ctx.logger.error("Failed to switch")
        return False  # Exception occurred, switch failed

# Asynchronous function to send a notification to a specific FCM token
async def send_notification_to_token(fcm_token, title, body, ctx: Context):
    # Create a message with the specified title and body
    ctx.logger.info("Sent notification for user")
    message = messaging.Message(
        notification=messaging.Notification(
            title=title,
            body=body
        ),
        token=fcm_token,
    )
    # Send the message to the specified FCM token
    try:
        response = messaging.send(message)
        print("Notification sent successfully:", response)
        return {"result": True, "data": response}  # Notification sent successfully
    except Exception as e:
        print("Error sending notification:", str(e))
        return {"result": False, "data": response}  # Error occurred while sending the notification


# Asynchronous function to fetch temperature data based on user's latitude and longitude
async def fetch_temperature(userData: UserData, ctx: Context):
    # Construct the API URL for weather data retrieval
    api_url = f"https://api.open-meteo.com/v1/forecast?latitude={userData.latitude}&longitude={userData.longitude}&current_weather=true"
    try:
        async with httpx.AsyncClient() as client:
            # Send a GET request to the weather API
            response = await client.get(api_url)
            data = response.json()
            
            # Extract the current temperature from the API response
            temperature = data.get("current_weather", {}).get("temperature", None)
            ctx.logger.info("Fetch Success")
            
            # Return the temperature data as a dictionary
            return {"result": True, "data": temperature}
    except Exception as e:
        # Handle exceptions and log any errors
        ctx.logger.error(f"Error fetching temperature data: {str(e)}")
        return {"result": False, "data": "Failed to fetch temperature"}

# Asynchronous function to alert users based on temperature data and send notifications
async def alert_on_temperature(userData: UserData, ctx: Context):
    # Fetch the current temperature data
    temperature = await fetch_temperature(userData=userData, ctx=ctx)
    
    if temperature["result"]:
        if temperature["data"] > userData.max_temperature:
            # If temperature is higher than the user's max temperature preference
            notification_body = await build_notification("HIGH")
            await switch_notification(userData.identifier, False, ctx)
            await send_notification_to_token(fcm_token=userData.fcm_token, title="High Temperature Alert", body=notification_body, ctx=ctx)
        elif temperature["data"] < userData.min_temperature:
            # If temperature is lower than the user's min temperature preference
            notification_body = await build_notification("LOW")
            await switch_notification(userData.identifier, False, ctx)
            await send_notification_to_token(fcm_token=userData.fcm_token, title="Low Temperature Alert", body=notification_body, ctx=ctx)


# Asynchronous function to load user data from the server
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
                        # Extract user data from the JSON response
                        allUserData = json_res["users"]
                        
                        # Iterate through the user data and create UserData objects
                        for user in allUserData:
                            objUser = UserData(
                                identifier=user["identifier"],
                                max_temperature=user["max_temp"],
                                min_temperature=user["min_temp"],
                                fcm_token=user["user_token"],
                                to_notify=user["notification"],
                                last_notified=user["last_notified"],
                                latitude=user["latitude"],
                                longitude=user["longitude"]
                            )
                            userList.append(objUser)
                        return userList
                    else:
                        ctx.logger.error("Server error: Failed to retrieve user data")
                        return False
                except Exception as json_error:
                    ctx.logger.error(f"Error parsing JSON response: {json_error}")
                    return False
            else:
                ctx.logger.error(f"Server returned status code: {response.status_code}")
                return False
    except Exception as e:
        ctx.logger.error(f"Exception occurred while fetching user data: {e}")



# Schedule the `check_temperature` function to run at regular intervals (every 30 seconds)
@temperature_alert_agent.on_interval(period=30)  
async def check_temperature(ctx: Context):
    # Load user data from the server
    userObjectsList = await loadUser(ctx=ctx)
    
    # Get the current time
    timenow = time.time()
    
    # Create a list to store users that need temperature notifications
    notifyCheckList = []
    
    # Iterate through the user data
    for user in userObjectsList:
        if user.to_notify:
            # Add users who have notifications enabled to the check list
            notifyCheckList.append(user)
        elif (timenow - user.last_notified) > 3600:
            # Add users who haven't been notified in the last hour and enable notifications
            res = await switch_notification(user.identifier, switch=True, ctx=ctx)
            notifyCheckList.append(user) if res else None
        else:
            ctx.logger.info("No User to Notify")
    
    # Send temperature alerts to users in the check list
    for notify in notifyCheckList:
        await alert_on_temperature(notify, ctx)

if __name__ == "__main__":
    # Initialize the Firebase Admin SDK with credentials
    cred = credentials.Certificate('climate-c11a3-firebase-adminsdk-dulsm-468c8ba2a9.json')
    firebase_admin.initialize_app(cred)
    
    # Start the temperature_alert_agent
    temperature_alert_agent.run()


