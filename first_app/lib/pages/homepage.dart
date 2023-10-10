import 'package:avatar_glow/avatar_glow.dart'; // Import for an avatar glow effect
import 'package:curved_navigation_bar/curved_navigation_bar.dart'; // Import for a curved navigation bar
import 'package:dio/dio.dart'; // Import for making HTTP requests
import 'package:cliMate/main.dart'; // Importing the main.dart file (check if needed)
import 'package:flutter/material.dart'; // Import for Flutter widgets
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Import for secure data storage
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'dart:convert'; // Import for working with JSON data
import 'package:geolocator/geolocator.dart'; // Import for geolocation services
import 'package:geocoding/geocoding.dart'; // Import for reverse geocoding
import 'package:intl/intl.dart'; // Import for date and time formatting
import 'package:google_fonts/google_fonts.dart'; // Import for using Google Fonts
import 'package:speech_to_text/speech_to_text.dart'
    as stts; // Import for speech-to-text functionality
import 'package:flutter_tts/flutter_tts.dart'; // Import for text-to-speech functionality
import '../services/api_service.dart'; // Importing an ApiService (check if needed)
import 'package:firebase_messaging/firebase_messaging.dart';

// void main() {
//   final storage = FlutterSecureStorage();
//   runApp(Dashboard(
//     userId: 'Test_user', // User ID
//     storage: storage, // Storage for secure data storage
//   ));
// }

class Dashboard extends StatelessWidget {
  final String userId; // User ID
  final FlutterSecureStorage storage; // Storage for secure data storage
  Dashboard({required this.userId, required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      home: BottomNavigationExample(
        userId: userId, // Pass the user ID to the dashboard
        storage: storage, // Pass the storage object to the dashboard
      ),
    );
  }
}

class BottomNavigationExample extends StatefulWidget {
  final String userId;
  final FlutterSecureStorage storage;
  BottomNavigationExample({required this.userId, required this.storage});

  @override
  _BottomNavigationExampleState createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  // Initialize the Flutter Text-to-Speech engine
  FlutterTts flutterTts = FlutterTts();

// Initialize the Speech-to-Text engine
  var _speechToText = stts.SpeechToText();

// Flag to track if speech recognition is currently active
  bool islistening = false;

// Index to track the current screen in the bottom navigation
  int _currentIndex = 0;

// Controller for managing page navigation
  final PageController _pageController = PageController();

// List of screens to be displayed in the app
  List<Widget> _screens = [];

// Stores the name of the selected city for weather information
  String _cityName = "";

// Stores the name of the currently displayed city
  String _currentCity = "";

// Stores the sentence spoken by user
  String inputWords = "";

// Stores the sentence to be spoken to user
  String outputWords = "";

  final GlobalKey<ForecastScreenState> forecastScreenKey =
      GlobalKey<ForecastScreenState>();

  @override
  void initState() {
    super.initState();

    // Initialize the speech recognition engine
    _speechToText = stts.SpeechToText();

    // Create a list of screens to be displayed in the app
    _screens = [
      HomeScreen(
        userId: widget.userId,
        storage: widget.storage,
        onCityChange: (city) {
          setState(() {
            _currentCity = city; // Update the currently selected city
          });
        },
      ),
      ForecastScreen(
        cityName: _cityName, // Pass the city name to the ForecastScreen
        storage: widget.storage,
      ),
      ProfileScreen(
        userId: widget.userId,
        storage: widget.storage,
      ),
    ];
  }

  // Function to start or stop speech recognition
  void listen() async {
    if (!islistening) {
      bool available = await _speechToText.initialize(
        // Initialize Speech-to-Text with event handlers
        onStatus: (status) => print(inputWords), // Handle status changes
        onError: (errorNotification) =>
            print("$errorNotification"), // Handle errors
      );
      if (available) {
        setState(() {
          islistening = true; // Set listening to true
        });
        _speechToText.listen(
          onResult: (result) => setState(() {
            var text = result.recognizedWords; // Update recognized speech text
          }),
        );
      }
    } else {
      setState(() {
        islistening = false; // Set listening to false
      });
      _speechToText.stop(); // Stop speech recognition
      _speak(); // Calls speak function when speech regonition stops
    }
  }

// Function to speak the recognized speech text
  void _speak() async {
    await flutterTts.speak(outputWords); // Use Flutter Text-to-Speech to speak text
  }

  @override
  void dispose() {
    // Dispose of the page controller when this widget is disposed.
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView to display different screens.
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() {
                // Update the current index when the page changes.
                _currentIndex = index;
              });
            },
          ),
          Positioned(
            // Positioned widget for microphone button.
            bottom: 0.0,
            right: 0.0,
            child: AvatarGlow(
              animate: islistening,
              repeat: true,
              endRadius: 60,
              glowColor: Colors.blue,
              duration: Duration(milliseconds: 2000),
              child: FloatingActionButton(
                onPressed: () {
                  // Call the listen function when the microphone button is pressed.
                  listen();
                },
                backgroundColor: Color.fromARGB(255, 77, 91, 102),
                child: Icon(islistening ? Icons.mic : Icons.mic_none, size: 32),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex, // The currently selected index.
        color: const Color.fromARGB(255, 92, 187,
            255), // Background color of the bottom navigation bar.
        buttonBackgroundColor: const Color.fromARGB(
            100, 240, 249, 255), // Background color of the active item.
        backgroundColor: const Color.fromARGB(
            100, 240, 249, 255), // Background color of the navigation bar.
        animationDuration: Duration(
            milliseconds: 300), // Duration of animation when switching tabs.
        height: 70.0, // Height of the bottom navigation bar.
        items: <Widget>[
          Icon(Icons.home, size: 35), // Icon for the Home tab.
          Icon(Icons.access_time, size: 35), // Icon for the Access Time tab.
          Icon(Icons.person, size: 35), // Icon for the Person tab.
        ],
        onTap: (index) {
          // Callback function when a tab is tapped.
          setState(() {
            _currentIndex = index; // Update the current index.
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            ); // Animate to the selected page.
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String userId;
  final Function(String) onCityChange; // Add this callback
  final FlutterSecureStorage storage;
  HomeScreen(
      {required this.userId,
      required this.onCityChange,
      required this.storage});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Dio dio = Dio();
  String _cityName = ""; // Stores the current city name.
  double _temperature = 0.0; // Stores the current temperature.
  double _humidity = 0; // Stores the current humidity.
  double _windSpeed = 0.0; // Stores the current wind speed.
  double _code = 0; // Stores the weather code.
  Image _image = Image.asset('assets/images/95.png',
      height: 200, fit: BoxFit.contain); // Default weather image.
  String _formattedDate =
      DateFormat('E, dd MMM').format(DateTime.now()); // Formatted date string.
  String _description = 'Loading...'; // Stores the current weather description.

// Map that associates weather codes with their descriptions.
  Map<int, String> weatherDescriptions = {
    0: 'Clear Sky',
    1: 'Mainly Clear',
    2: 'Partly Cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Depositing Rime Fog',
    51: 'Light Drizzle',
    53: 'Moderate Drizzle',
    55: 'Dense Drizzle',
    56: 'Light Freezing Drizzle',
    57: 'Dense Freezing Drizzle',
    61: 'Slight Rain',
    63: 'Moderate Rain',
    65: 'Heavy Rain',
    66: 'Light Freezing Rain',
    67: 'Heavy Freezing Rain',
    71: 'Slight Snow Fall',
    73: 'Moderate Snow Fall',
    75: 'Heavy Snow Fall',
    77: 'Snow Grains',
    80: 'Slight Rain Showers ',
    81: 'Moderate Rain Showers',
    82: 'Violent Rain Showers',
    85: 'Slight Snow Showers',
    86: 'Heavy Snow Showers',
    95: 'Moderate Thunderstorm',
    96: 'Slight Hail Thunderstorm',
    99: 'Heavy Hail Thunderstorm',
  };

  Future<void> _fetchWeatherForCurrentLocation() async {
    final apiService = ApiService(dio);
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final cityName =
          placemarks.first.locality; // Get the city name from placemarks.
      print(cityName);
      await widget.storage.write(key: 'city', value: cityName);
      String? token = await widget.storage.read(key: 'access_token');
      String? fcToken = await widget.storage.read(key: 'fc_token');
      final dashboardData = await apiService.getDashboardData(
        'Token $token',
        {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'fc_token': fcToken
        },
      );
      setState(() {
        _cityName = cityName!; // Update the city name.
        _temperature = dashboardData.temperature; // Update the temperature.
        _code = dashboardData.weathercode; // Update the weather code.
        _humidity = dashboardData.humidity; // Update the humidity.
        _windSpeed = dashboardData.windspeed; // Update the wind speed.
        _image =
            getImageForCode(_code.toInt()); // Get and update the weather image.
        _description = weatherDescriptions[_code.toInt()] ??
            'Sunny Weather'; // Update the weather description.
      });
    }
  }

  Future<void> _fetchWeatherData({
    String cityName = 'None',
    double latitude = 0.0,
    double longitude = 0.0,
  }) async {
    final apiService = ApiService(dio);

    try {
      Map<String, dynamic> requestBody;

      if (cityName == 'None') {
        // If cityName is not provided, fetch weather data by latitude and longitude.
        requestBody = {
          'latitude': latitude,
          'longitude': longitude,
        };
      } else {
        // If cityName is provided, fetch weather data by city name.
        requestBody = {'locationName': '$cityName'};
        await widget.storage.write(key: 'city', value: cityName);

        // Update the local state and notify the parent widget about the city change.
        setState(() {
          _cityName = cityName;
          widget.onCityChange(cityName);
        });
      }

      // Write the selected city to storage for future reference.
      await widget.storage.write(key: 'city', value: cityName);

      // Get the user's access token from storage.
      String? token = await widget.storage.read(key: 'access_token');

      // Fetch weather data from the API using the provided request body.
      final response = await apiService.getDashboardData(
        'Token $token',
        requestBody,
      );

      print(response);

      // Update the local state with the fetched weather data.
      setState(() {
        _cityName = cityName;
        _temperature = response.temperature;
        _code = response.weathercode;
        _humidity = response.humidity;
        _windSpeed = response.windspeed;
        _image = getImageForCode(_code.toInt());
        _description = weatherDescriptions[_code.toInt()] ?? 'Sunny Weather';
      });
    } catch (e) {
      print('Error, $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherForCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color.fromARGB(255, 240, 249, 255),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Stack(
            children: [
              // Background Container for the top 50% of the screen
              Positioned(
                  top: 10,
                  left: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.83,
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 190, 228, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 32,
                        ), // Location icon on the left
                        SizedBox(width: 10), // Add some spacing
                        Text(
                          _cityName.isEmpty
                              ? 'cli-Mate'
                              : _cityName.toUpperCase(),
                          style: GoogleFonts.alata(
                            backgroundColor:
                                const Color.fromARGB(255, 190, 228, 255),
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(width: 10), // Add some spacing
                        GestureDetector(
                          onTap: () {
                            _showSearchDialog(context, '');
                          },
                          child: const Icon(
                            Icons.search,
                            size: 32,
                          ),
                        ), // Search icon on the right
                      ],
                    ),
                  )),
              Positioned(
                top: 100,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height * 0.37,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 175, 222, 255),
                        Color.fromARGB(255, 6, 123, 208)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Positioned(
                top: 80, // Position below the container
                left: 20,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _temperature.toString() + '°',
                        style: GoogleFonts.alumniSans(
                          fontSize: 132,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Add more content here
                    ],
                  ),
                ),
              ),
              // Image positioned half inside and half outside the container
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.29, // Adjust the position as needed
                left: 0,
                right: 0,
                child: _image,
              ),
              // Content (temperature) below the container
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.55, // Position below the container
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _description,
                        style: GoogleFonts.alata(
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Add more content here\
                      Text(
                        _formattedDate,
                        style: GoogleFonts.alata(
                          fontSize: 20,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.68,
                left: 0,
                right: 0,
                height: 80,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 92, 187, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height *
                    0.68, // Position below the container
                left: MediaQuery.of(context).size.width * 0.07,
                right: MediaQuery.of(context).size.width * 0.1,
                child: Container(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.water,
                        size: 40,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10), // Add some vertical spacing
                      Column(
                        children: [
                          Text(
                            _humidity.toString() +
                                '%', // Replace with actual humidity value
                            style: GoogleFonts.alata(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Humidity', // Replace with actual humidity value
                            style: GoogleFonts.alata(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      const Icon(
                        Icons.speed,
                        size: 40,
                        color: Colors.white,
                      ), // Wind speed icon
                      SizedBox(height: 10), // Add some vertical spacing
                      Column(
                        children: [
                          Text(
                            _windSpeed.toString() +
                                'km/h', // Replace with actual wind speed value
                            style: GoogleFonts.alata(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Wind Speed', // Replace with actual wind speed value
                            style: GoogleFonts.alata(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context, _message) {
    String newCityName =
        ""; // Initialize a variable to store the entered city name
    String error = _message; // Store any error message received

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Weather'), // Dialog title
          content: TextField(
            onChanged: (value) {
              newCityName =
                  value; // Update the newCityName variable as the user types
            },
            decoration: const InputDecoration(
              hintText:
                  'Enter city name', // Placeholder text for the text field
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog when "Cancel" is pressed
              },
              child: Text('Cancel'), // "Cancel" button text
            ),
            TextButton(
              onPressed: () {
                _fetchWeatherData(
                    cityName:
                        newCityName); // Fetch weather data for the entered city
                Navigator.of(context).pop(); // Close the dialog after searching
              },
              child: Text('Search'), // "Search" button text
            ),
            if (error.isNotEmpty)
              Text(
                  "Location Not Found!") // Display an error message if it's not empty
          ],
        );
      },
    );
  }

  Image getImageForCode(int code) {
    // Various weather condition codes with corresponding images
    switch (code) {
      case 0:
        return Image.asset(
          'assets/images/0.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 1:
        return Image.asset(
          'assets/images/123.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 2:
        return Image.asset(
          'assets/images/123.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 3:
        return Image.asset(
          'assets/images/123.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 77:
        return Image.asset(
          'assets/images/77.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 95:
        return Image.asset(
          'assets/images/95.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 45:
        return Image.asset(
          'assets/images/4548.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 48:
        return Image.asset(
          'assets/images/4548.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 56:
        return Image.asset(
          'assets/images/5657.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 57:
        return Image.asset(
          'assets/images/5657.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 66:
        return Image.asset(
          'assets/images/6667.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 67:
        return Image.asset(
          'assets/images/6667.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 85:
        return Image.asset(
          'assets/images/8586.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 86:
        return Image.asset(
          'assets/images/8586.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 96:
        return Image.asset(
          'assets/images/9699.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 99:
        return Image.asset(
          'assets/images/9699.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 51:
        return Image.asset(
          'assets/images/515355.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 53:
        return Image.asset(
          'assets/images/515355.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 55:
        return Image.asset(
          'assets/images/515355.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 61:
        return Image.asset(
          'assets/images/616365.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 63:
        return Image.asset(
          'assets/images/616365.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 65:
        return Image.asset(
          'assets/images/616365.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 71:
        return Image.asset(
          'assets/images/717375.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 73:
        return Image.asset(
          'assets/images/717375.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 75:
        return Image.asset(
          'assets/images/717375.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 80:
        return Image.asset(
          'assets/images/808182.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 81:
        return Image.asset(
          'assets/images/808182.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 82:
        return Image.asset(
          'assets/images/808182.png',
          height: 220,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      default:
        return Image.asset(
          'assets/images/4548.png',
          height: 1,
          width: 220, // Cover the entire width
          fit: BoxFit.contain,
        ); // A default image for unknown values
    }
  }
}

class ForecastScreen extends StatefulWidget {
  final FlutterSecureStorage storage;
  final String cityName;
  ForecastScreen({required this.cityName, required this.storage});

  @override
  ForecastScreenState createState() => ForecastScreenState();
}

class ForecastScreenState extends State<ForecastScreen> {
  // Create an instance of Dio for making HTTP requests
  final Dio dio = Dio();

// Initialize an empty list to store weather forecast data
  List<WeatherForecast> _forecastData = [];

// Initialize the default city name to "Mumbai"
  String _cityName = "Mumbai";

  @override
  void initState() {
    super.initState();

    // Check if a city name is available
    if (_cityName != null) {
      // Fetch weather forecast data for the default city
      _fetchWeatherForecast(_cityName);
    } else {
      print("City not found");
    }
  }

// Function to update the displayed city and fetch weather forecast data
  void updateCityName(String cityName) {
    _fetchWeatherForecast(cityName);
  }

  // Fetch weather forecast data for a given city
  Future<void> _fetchWeatherForecast(String cityName) async {
    final apiService = ApiService(dio);

    // Retrieve the selected city name from storage and update the display
    cityName = (await widget.storage.read(key: 'city'))!;
    setState(() {
      _cityName = cityName.toUpperCase();
    });

    // Prepare the request body with the selected city name
    Map<String, dynamic> requestBody;
    requestBody = {'locationName': cityName};

    // Retrieve the user's access token from storage
    String? token = await widget.storage.read(key: 'access_token');

    try {
      // Fetch forecast data from the API using the access token and request body
      final data1 = await apiService.getForecastData(
        'Token $token',
        requestBody,
      );

      List<WeatherForecast> forecasts = [];
      final data = data1.forecast;

      // Parse the fetched data into WeatherForecast objects
      for (var item in data) {
        forecasts.add(WeatherForecast(
          date: DateTime.parse(item.date as String),
          minTemperature: item.min,
          maxTemperature: item.max,
          code: item.weatherCode,
        ));
      }

      setState(() {
        // Update the displayed city name and forecast data
        _cityName = cityName.toUpperCase();
        _forecastData = forecasts;
      });
    } catch (e) {
      print("Error fetching forecast data: $e");
      // Handle the error, e.g., show an error message to the user
    }
  }

// Various weather condition codes with corresponding images
  Image getImageForCode(int code) {
    switch (code) {
      case 0:
        return Image.asset(
          'assets/images/0.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 1:
        return Image.asset(
          'assets/images/123.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 2:
        return Image.asset(
          'assets/images/123.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 3:
        return Image.asset(
          'assets/images/123.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 77:
        return Image.asset(
          'assets/images/77.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 95:
        return Image.asset(
          'assets/images/95.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 45:
        return Image.asset(
          'assets/images/4548.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 48:
        return Image.asset(
          'assets/images/4548.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 56:
        return Image.asset(
          'assets/images/5657.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 57:
        return Image.asset(
          'assets/images/5657.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 66:
        return Image.asset(
          'assets/images/6667.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 67:
        return Image.asset(
          'assets/images/6667.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 85:
        return Image.asset(
          'assets/images/8586.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 86:
        return Image.asset(
          'assets/images/8586.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 96:
        return Image.asset(
          'assets/images/9699.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 99:
        return Image.asset(
          'assets/images/9699.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 51:
        return Image.asset(
          'assets/images/515355.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 53:
        return Image.asset(
          'assets/images/515355.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 55:
        return Image.asset(
          'assets/images/515355.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 61:
        return Image.asset(
          'assets/images/616365.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 63:
        return Image.asset(
          'assets/images/616365.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 65:
        return Image.asset(
          'assets/images/616365.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 71:
        return Image.asset(
          'assets/images/717375.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 73:
        return Image.asset(
          'assets/images/717375.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 75:
        return Image.asset(
          'assets/images/717375.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 80:
        return Image.asset(
          'assets/images/808182.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 81:
        return Image.asset(
          'assets/images/808182.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 82:
        return Image.asset(
          'assets/images/808182.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        );
      default:
        return Image.asset(
          'assets/images/4548.png',
          height: 80,
          width: 80, // Cover the entire width
          fit: BoxFit.contain,
        ); // A default image for unknown values
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          // Wrap everything in a ListView
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              width: MediaQuery.of(context).size.width * 0.8,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 190, 228, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _cityName.isEmpty
                    ? 'Weather Forecast'
                    : '$_cityName\'s Forecast',
                style: GoogleFonts.alata(
                  fontSize: 22,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            ListView.builder(
              itemCount: _forecastData.length,
              shrinkWrap: true, // Ensure the inner ListView scrolls correctly
              physics:
                  NeverScrollableScrollPhysics(), // Disable outer ListView scrolling
              itemBuilder: (context, index) {
                final forecast = _forecastData[index];
                final date = DateFormat('EEE, MMM d').format(forecast.date);
                final weatherCode = forecast.code;
                final image = getImageForCode(weatherCode as int);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    elevation: 4, // Adjust elevation as needed
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        gradient: const RadialGradient(
                          center: Alignment(0.0, 0.0),
                          radius: 2,
                          colors: [
                            Color.fromARGB(255, 152, 212, 255),
                            Color.fromARGB(255, 70, 177, 255),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left side: Date
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${forecast.minTemperature}°C / ${forecast.maxTemperature}°C',
                                  style: GoogleFonts.alumniSans(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                Text(
                                  date,
                                  style: GoogleFonts.archivo(
                                      fontSize: 20, color: Colors.white),
                                ),
                              ],
                            ),
                            // Right side: Weather Image
                            image,
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}

class WeatherForecast {
  final DateTime date;
  final double minTemperature;
  final double maxTemperature;
  final int code;

  WeatherForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.code,
  });
}

class ProfileScreen extends StatefulWidget {
  final String userId;
  final FlutterSecureStorage storage;
  ProfileScreen({required this.userId, required this.storage});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final Dio dio = Dio();
  double _minTemperature = -50.0;
  double _maxTemperature = 70.0;
  String _userName = "";
  String _message = "";

  @override
  void initState() {
    super.initState();
    // Call the function to fetch user data when the widget initializes
    fetchUserData();
  }

// Function to fetch user data, you can add your implementation here
  void fetchUserData() async {
    // Implement code to fetch user data, if needed
  }

// Function to update temperature settings
  void updateTemperatureSettings() async {
    final apiService = ApiService(dio);
    try {
      // Check if the minimum temperature is greater than or equal to the maximum temperature
      if (_minTemperature >= _maxTemperature) {
        setState(() {
          _message = "Error! Minimum Temperature should be lesser";
        });
      } else {
        setState(() {
          _message = "";
        });
        String? token = await widget.storage.read(key: 'access_token');
        final body = {
          "min_temperature": _minTemperature,
          "max_temperature": _maxTemperature,
        };
        // Call the API to set temperature preferences
        await apiService.setTemperaturePreferences('Token $token', body);
        setState(() {
          _message = 'Preferences saved successfully.';
        });
        // Update the stored minimum and maximum temperature values
        widget.storage.write(key: 'mintemp', value: _minTemperature.toString());
        widget.storage.write(key: 'maxtemp', value: _maxTemperature.toString());
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 240, 249, 255),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),

              // Profile Title
              Container(
                width: 350,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 190, 228, 255),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Profile',
                  style: GoogleFonts.alata(
                    fontSize: 26,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // User Profile
              Column(
                children: [
                  // User Avatar
                  const CircleAvatar(
                    radius: 70.0,
                    backgroundColor: Color.fromARGB(255, 196, 196, 196),
                    backgroundImage: AssetImage(
                      'assets/images/profile_image.png',
                    ),
                  ),
                  SizedBox(height: 16.0),

                  // User ID
                  Container(
                    height: 80,
                    width: 300,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 175, 222, 255),
                          Color.fromARGB(255, 6, 123, 208)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(44.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.userId,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.alata(
                          fontSize: 33.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),

              // Temperature Sliders
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Minimum Temperature Slider
                  SizedBox(height: 8.0),
                  Text(
                    'Minimum Temperature: $_minTemperature °C',
                    style: GoogleFonts.alata(
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: _minTemperature,
                    onChanged: (value) {
                      setState(() {
                        _minTemperature = value;
                      });
                    },
                    min: -50.0,
                    max: 70.0,
                    divisions: 120,
                    label: '$_minTemperature °C',
                  ),
                  SizedBox(height: 16.0),

                  // Maximum Temperature Slider
                  SizedBox(height: 16.0),
                  Text(
                    'Maximum Temperature: $_maxTemperature °C',
                    style: GoogleFonts.alata(
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: _maxTemperature,
                    onChanged: (value) {
                      setState(() {
                        _maxTemperature = value;
                      });
                    },
                    min: -50.0,
                    max: 70.0,
                    divisions: 120,
                    label: '$_maxTemperature °C',
                  ),
                ],
              ),

              // Save Settings Button
              Text(
                _message,
                style: GoogleFonts.alata(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color:
                      _message.startsWith("Error") ? Colors.red : Colors.green,
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    updateTemperatureSettings();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 92, 187, 255),
                    padding:
                        EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    'Save Preferences',
                    style: GoogleFonts.alata(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              // Logout Button
              SizedBox(height: 16.0),
              Container(
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ElevatedButton(
                  onPressed: () async {
                    // Handle user logout, e.g., deleting access token and navigating to the landing page
                    await widget.storage.delete(key: 'access_token');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            LandingPage(storage: widget.storage),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 92, 187, 255),
                    padding:
                        EdgeInsets.symmetric(vertical: 9.0, horizontal: 40.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: GoogleFonts.alata(
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
