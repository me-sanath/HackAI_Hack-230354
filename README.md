
# cli-Mate - Your Personal Weather Companion

cli-Mate is a feature-rich weather app designed to be your ultimate weather companion. With cli-Mate, you can stay informed about the current weather conditions and forecasts for any location around the world. Whether you're planning a trip, getting ready for outdoor activities, or just want to know what to expect outside, cli-Mate has you covered.

## Table of Contents
- [About](#about)
  - [What is cli-Mate](#what-is-cli-mate)
  - [Features](#features)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [TECH STACK used](#techstack---built-with)
- [Screenshots](#screenshots)
- [Team](#the-team)

## About
### What is cli-Mate?
 In today's fast-paced world, staying prepared for changing weather conditions is more critical than ever. Weather can impact daily routines, travel plans, and outdoor activities, but many weather apps often fall short in providing accurate, easy-to-understand information and personalized notifications. That's where cli-Mate comes in.

  Developed with a focus on user-friendliness and accessibility, cli-Mate is a cutting-edge weather application designed to empower users with comprehensive weather data and intelligent features. It offers precise weather forecasts while allowing users to set temperature limits and receive notifications for high and low temperatures.

  What sets cli-Mate apart is its advanced voice assistant, powered by Natural Language Processing (NLP). This voice assistant provides instant, conversational weather updates and enables users to configure temperature preferences through natural dialogue, offering a highly personalized weather experience.

  Under the hood, cli-Mate seamlessly integrates various programming languages and technologies. It's built with Dart and Flutter for its intuitive user interface, communicates with real-time weather data using REST APIs and JSON, relies on Django, a high-level Python web framework, for its back-end operations, and features an NLP-driven voice assistant to enhance accessibility and user-friendliness.

cli-Mate's mission is to simplify the way people interact with weather information and equip them with the tools needed to plan their lives effectively in an ever-changing climate.

### Features

- **Personalized Notifications**
  - Set temperature limits and get instant notifications for weather changes.
  - Adapt to changing conditions effortlessly.

- **Real-Time Weather Data**
  - Access live weather info: temperature, wind speed, humidity, and more.
  - Make informed decisions with up-to-the-minute updates.

- **Voice Assistance (NLP)**
  - Utilize advanced Natural Language Processing (NLP) for seamless voice interaction.
  - Interact with cli-Mate using voice commands for a user-friendly experience.

- **7-Day Weather Forecast (Forecast)**
  - Plan your week confidently with a detailed 7-day forecast.
  - Know daily minimum and maximum temperatures for effective scheduling.

- **Location-Based Weather**
  - Get accurate weather data based on your location.
  - Easily access weather updates for any city or region, ensuring preparedness.

- **Stunning Visuals**
  - Immerse yourself in captivating weather visuals reflecting current conditions.
  - Enjoy an engaging weather experience with beautiful icons.

- **User-Friendly Interface**
  - Navigate cli-Mate effortlessly with an intuitive interface.
  - Users of all ages can access and customize weather data easily.

- **Secure Data Storage**
  - Protect your settings and location preferences with secure storage.
  - Your data is accessible only to you, ensuring privacy and security.


## Getting Started
## Prerequisites

Before you begin, ensure that you have the following prerequisites installed on your development environment:

1. **Python**: You'll need Python installed to run backend scripts microagents. You can download Python from the official website [here](https://www.python.org/downloads/).

2. **Flutter with Android Studio**: To build and run the cli-Mate application, you must have Flutter and Android Studio installed. Follow the installation instructions for Flutter and Android Studio based on your operating system:

   - [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)
   - [Android Studio Installation Guide](https://developer.android.com/studio)

3. **Android SDK**: Android Studio usually comes with the Android SDK, but it's essential to ensure it's correctly installed and configured. Android SDK is necessary for building and running Android applications with Flutter.

Make sure all the required paths are added to PATH in environment variables of you PC.

After installing Flutter and Android Studio, it's highly recommended to run the following command to check for any additional requirements or corrections in your Flutter environment:

```bash
flutter doctor
```

## Installation
We have already hosted the server on AWS for you :)
You can just skip to to get started with cli-Mate using our Pre-Built apk and server hosted on AWS.
Or
Set up the server and compile the app yourself with instructions provided.

Feel free to reach out to us if you have trouble following the guide. Contact details can be found [here](#the-team)

**⚠️ Important Notice:** Please note that the NLP (Natural Language Processing) features in the APK provided may not function as expected due to the absence of GPU support on our server. While we have made every effort to offer a fully functional app, voice assistance capabilities might be limited in this version. We appreciate your understanding, and we are continuously working to enhance the app's performance and features.

**Note**: Please be aware that there might be a delay in receiving notifications from the server notifier. This delay has been intentionally set higher to avoid exceeding the rate limit imposed by the open meteo weather API we rely on for real-time weather data. We appreciate your understanding, and rest assured that we have implemented this delay to ensure the continued reliability.


### Option 1: Use Our Pre-Built APK File and server hosted on AWS

1. **APK File Link**: You can download the pre-built APK file from [this link](https://drive.google.com/drive/folders/1UoZ2xSYXxeaGHCdkZjsd1ZVx4tyctLRR?usp=sharing).

2. **Installation**: After downloading the APK file, install it on your Android device.

3. **⚠️ Permissions**: Make sure to allow the required permissions when prompted during installation. If you don't receive any prompts, you can configure permissions in your device settings. The app requires notification, location, and microphone permissions for proper functioning.

4. **Usage**: Once installed and permissions granted, launch the app to start using cli-Mate.

### Option 2: Run Server Locally and Compile the App

## Running the Server:

1. **Clone the Repository**: Begin by cloning the cli-Mate repository from GitHub to your local machine. This step ensures you have the server's source code.
    ```bash
    git clone https://github.com/me-sanath/HackAI_Hack-230354.git
    ```
2. **Create a Virtual Environment**: It's a good practice to work in a virtual environment to manage dependencies cleanly. Create a virtual environment using your preferred method. For example, you can use Python's `virtualenv` or `venv`.

    While in cloned directory, run
    ```bash
    python -m venv .venv
    ```
3. **Activate the Virtual Environment**: Activate the virtual environment to isolate your project's dependencies. This step ensures that you work within a controlled environment for your server.

    - On Windows
      ```bash
      .venv\Scripts\activate
      ```
    - On macOs and Linux
      ```bash
      source .venv/bin/activate
      ```
4. **Install Requirements**: Use `pip` to install the required Python packages specified in the `requirements.txt` file. These packages are essential for the server's proper functioning.

    ```bash
    pip install -r requirements.txt
    ```
5. **Database Migration**: Apply the database migrations. This step ensures that your database schema is up to date.


    ```bash
    python manage.py migrate
    ```
    
6. **Create Super**: Create a super user for the supertoken required for uagents and without login weather fetch token.

    ```bash
    python manage.py createsuperuser
    ```
    Follow the instructions on screen

7. **Postman Request**: Send postman request to `http://your-server-address/api/login/` 

   Json body : Form data must contain email with superuser email and password of superuser
      ```python
      {
      "token": "your-identifier",
      "user_id": user-id,
      "username": "username"
      }
      ```
   Copy and paste this identifier in `weather_agents.py` file where indicated
   
9. **Start the Server**: Launch the server with the given command. This action starts the server locally, and it will be accessible at the specified address (usually `http://localhost:8000/`).

    ```bash
    python manage.py runserver
    ```
## Running the uagent for notifications
  All the keys for running notifier is already added in the uagents

  **Change URL** If server is run locally, change the adress in the base url with local address.

  ** Run this command to start notifier server:
    ```bash
    python weather_agent.py
    ```
## Compiling the App:

1. **Navigate to App Directory**: If you haven't already, navigate to the directory containing the Flutter app code. In this case, it appears to be in the "first_app" directory.

    ```bash
    cd first_app/
    ```
2. **Get Dependencies**: Run `flutter pub get` to fetch and install the necessary Flutter dependencies for the app. This step ensures that your app has access to required packages.

    ```bash
    flutter pub get
    ```
4. **Update Server Adress**: Before proceeding, ensure you have the server address where your backend is hosted. Open the api_service.dart and api_service.g.dart files located in `first_app/lib/service/`. Update server adress in base url of retrofitted API class. If you cannot find it, search for `CHANGELINK` keyword which is commented.

5. **Build and Run**: Use `dart run build_run run` to build and run the app. This command will compile the app and make it ready for execution.
    ```bash
    dart run build_run run
    ```
4. **Connect Android Device or Emulator**: Ensure your Android device is connected to your computer via USB, and USB debugging is enabled in developer mode. Alternatively, you can use an emulator to test the app.
  
5. **Launch the App**: Run `flutter run` after selecting the target device or emulator. This command will install and launch the app on the specified device.

These steps will help you set up and run both the server and the app smoothly. You're now ready to go!




## TECHSTACK - Built with
<div style="display: flex; justify-content: center; gap: 50px;align-items: center;">
    <img src="https://github.com/me-sanath/cli-Mate/assets/120031221/6212cefe-88af-4dc8-80e5-397a7b0d68c8" width="45%">
    <img src="https://github.com/me-sanath/cli-Mate/assets/120031221/eb4f8036-f5d6-4bb8-bdf5-c274886c0535" width="45%">
</div>


[![Tech](https://skillicons.dev/icons?i=flutter,dart,python,django,firebase,aws)](https://skillicons.dev)

μAgents, Flutter, Dart, Python, Django, Firebase, AWS

API: Open Meteo

μAgents:
μAgents is a versatile software framework for creating autonomous agent systems.

Flutter:
Flutter is Google's UI toolkit for building natively compiled apps for various platforms.

Dart:
Dart is a fast, modern programming language primarily used in Flutter development.

Python:
Python is a versatile and readable programming language used in web development, data analysis, and more.

Django:
Django is a high-level Python web framework known for its simplicity and robust features.

Firebase:
Firebase is Google's mobile and web app development platform with a wide range of tools and services.


## Screenshots

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/39a98f08-e0e4-4c53-a5e5-fdafa13e4396" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/a8cfd3ef-b07c-4275-a332-ae796d90dd85" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/7fb69a1d-d7e0-453c-8973-5d87696c3c72" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/df863956-a821-4e8a-ba8e-1359780768a5" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/aa6cc8b1-5af5-4445-a9d8-d67b2e38ecc9" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/4837012c-6963-4c0a-80af-01e2b7c62613" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/e48fa3f0-081d-4177-bb5c-91539ef647d1" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/d30d0a61-cd01-424c-9173-fd44adebe4cc" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/8b5d6d6a-9ecc-42e2-9674-1be0de356226" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/2a51e720-5a34-4bfb-b3fb-4e6335bf376d" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/b291643e-b001-4274-84bf-31d9345c70ae" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/11b5fc44-4779-4d32-a0f0-0505bce1a704" width="200">

<img src="https://github.com/me-sanath/cli-Mate/assets/119714743/16be71be-dad7-4f29-8b26-e6af3c6bf585" width="200">



## The Team:
**Sanath Naik**

[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/me-sanath)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/sanath-naik/)

**Pranav Anantha Rao**

[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/PranavRao18)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/pranav-rao-b00926223/)

**K L Gireesh**

[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/Gireesh-KL)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/k-l-gireesh-b9b16027b/)

**Satwik Kini**

[![GitHub](https://img.shields.io/badge/GitHub-black?style=flat&logo=github)](https://github.com/satwikkini-01)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-blue?style=flat&logo=linkedin)](https://www.linkedin.com/in/satwik-kini-26a949252/)
