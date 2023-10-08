import 'package:avatar_glow/avatar_glow.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:first_app/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stts;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

//cant run this for now ;-;
//to run the current page, uncomment:
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  runApp(Dashboard(prefs: prefs));
}

class Dashboard extends StatelessWidget {
  final SharedPreferences prefs;

  Dashboard({required this.prefs});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationExample(prefs: prefs),
    );
  }
}

class BottomNavigationExample extends StatefulWidget {
  final SharedPreferences prefs;

  BottomNavigationExample({required this.prefs});

  @override
  _BottomNavigationExampleState createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  FlutterTts flutterTts = FlutterTts();
  var _speechToText = stts.SpeechToText();
  bool islistening = false;
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<Widget> _screens = [];
  String text = "";

  final GlobalKey<ForecastScreenState> forecastScreenKey =
      GlobalKey<ForecastScreenState>();

  @override
  void initState() {
    super.initState();
    _speechToText = stts.SpeechToText();
    _screens = [
      HomeScreen(
        prefs: widget.prefs,
      ),
      ForecastScreen(
        prefs: widget.prefs,
      ),
      ProfileScreen(prefs: widget.prefs),
    ];
  }

  void listen() async {
    if (!islistening) {
      bool available = await _speechToText.initialize(
        onStatus: (status) => print(text),
        onError: (errorNotification) => print("$errorNotification"),
      );
      if (available) {
        setState(() {
          islistening = true;
        });
        _speechToText.listen(
          onResult: (result) => setState(() {
            text = result.recognizedWords;
          }),
        );
      }
    } else {
      setState(() {
        islistening = false;
      });
      _speechToText.stop();
    }
  }

  void _speak() async {
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            children: _screens,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Positioned(
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
                  listen();
                  // _speak();
                  // Satwik your stuff should be here
                  // Handle microphone button tap
                  // Add your microphone functionality here
                },
                backgroundColor: Color.fromARGB(255, 92, 187, 255),
                child: Icon(islistening ? Icons.mic : Icons.mic_none, size: 32),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        color: const Color.fromARGB(255, 92, 187, 255),
        buttonBackgroundColor: const Color.fromARGB(100, 240, 249, 255),
        backgroundColor: const Color.fromARGB(100, 240, 249, 255),
        animationDuration: Duration(milliseconds: 300),
        height: 70.0,
        items: <Widget>[
          Icon(Icons.home, size: 35),
          Icon(Icons.access_time, size: 35),
          Icon(Icons.person, size: 35),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.ease,
            );
          });
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final SharedPreferences prefs;

  HomeScreen({required this.prefs});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController _cityController = TextEditingController();
  String _cityName = "";
  double _temperature = 0.0;
  double _humidity = 0;
  double _windSpeed = 0.0;
  double _code = 0;
  Image _image =
      Image.asset('assets/images/95.png', height: 200, fit: BoxFit.contain);
  String _formattedDate = DateFormat('E, dd MMM').format(DateTime.now());

  Future<void> _fetchWeatherForCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      final cityName = placemarks.first.subAdministrativeArea;
      widget.prefs.setString('cityName', cityName!);
      print(cityName);
      _fetchWeatherData(
          latitude: position.latitude, longitude: position.longitude);
      setState(() {
        _cityName = cityName;
      });
    }
  }

  Future<void> _fetchWeatherData(
      {String cityName = 'None',
      double latitude = 0.0,
      double longitude = 0.0}) async {
    final String? token = widget.prefs.getString('token');
    try {
      final Uri url = Uri.parse(
          'https://955e-2406-7400-81-cff7-401b-682d-c52-e4d5.ngrok-free.app/weather/dashboard/');
      final Map<String, String> headers = {
        'Authorization':
            'Token 1efc2cf63dc81c2241885f6a2862486b5d05cb7a', // TODO
        'Content-Type': 'application/json',
      };
      Map<String, dynamic> requestBody;

      if (cityName == 'None') {
        requestBody = {
          'latitude': latitude,
          'longitude': longitude,
        };
      } else {
        widget.prefs.setString('cityName', cityName);
        requestBody = {'locationName': '$cityName'};
        setState(() {
          _cityName = cityName;
        });
      }
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print(response.body);
        final data = jsonDecode(response.body);
        final data1 = data["data"];
        setState(() {
          //_cityName = cityName!;
          _temperature = data1['temperature'];
          _humidity = data1['humidity'].toDouble();
          _windSpeed = data1['windspeed'];
          _code = data1['weathercode'].toDouble();
          _image = getImageForCode(_code.toInt());
        });
        // widget.onCityChange(cityName!);
      } else {
        print('Failed to fetch weather data: ${response.statusCode}');
      }
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
      // appBar: AppBar(
      //   title: Text(_cityName.isEmpty ? 'Weather App' : _cityName),
      //   actions: [
      //     IconButton(
      //       icon: Icon(Icons.search),
      //       onPressed: () {
      //         _showSearchDialog(context);
      //       },
      //     ),
      //   ],
      // ),
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
                        Icon(
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
                            fontSize: 19,
                          ),
                        ),
                        SizedBox(width: 10), // Add some spacing
                        GestureDetector(
                          onTap: () {
                            _showSearchDialog(context, '');
                          },
                          child: Icon(
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
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 175, 222, 255),
                        const Color.fromARGB(255, 6, 123, 208)
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
                        'Sunny Weather',
                        style: GoogleFonts.alata(
                          fontSize: 28,
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
                      Icon(
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
                      Icon(
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
    String newCityName = "";
    String error = _message;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Search Weather'),
          content: TextField(
            controller: _cityController,
            onChanged: (value) {
              newCityName = value;
            },
            decoration: InputDecoration(
              hintText: 'Enter city name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                widget.prefs.setString('cityName', newCityName);
                _fetchWeatherData(cityName: newCityName);
                Navigator.of(context).pop();
              },
              child: Text('Search'),
            ),
            if (error.isNotEmpty) Text("Location Not Found!")
          ],
        );
      },
    );
  }

  Image getImageForCode(int code) {
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
  final SharedPreferences prefs;

  ForecastScreen({required this.prefs});

  @override
  ForecastScreenState createState() => ForecastScreenState();
}

class ForecastScreenState extends State<ForecastScreen> {
  List<WeatherForecast> _forecastData = [];
  String _cityName = "";

  @override
  void initState() {
    super.initState();
    String? _cityName = widget.prefs.getString('cityName');
    if (_cityName != null) {
      _fetchWeatherForecast(_cityName);
    } else {
      print("City not found");
    }
  }

  void updateCityName(String cityName) {
    _fetchWeatherForecast(cityName);
  }

  Future<void> _fetchWeatherForecast(String cityName) async {
    print("Hello");
    print(cityName);
    final response = await http.get(
      Uri.parse(
        // Sanath, forecast details here
        'http://your-django-api-url/forecast?city=$cityName', // Replace with your weather forecast API URL
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
    List<WeatherForecast> forecasts = [];

      for (var item in data) {
        forecasts.add(WeatherForecast(
          date: DateTime.parse(item['date']),
          minTemperature: item['min_temperature'],
          maxTemperature: item['max_temperature'],
          code: item['weathearCode'],
        ));
      }

      setState(() {
        _cityName = cityName;
        _forecastData = forecasts;
      });
    } else {
      print('Failed to fetch weather forecast data: ${response.statusCode}');
    }
  }

  Image getImageForCode(int code) {
    switch (code) {
      case 0:
        return Image.asset(
          'assets/images/0.png',
          height: 80,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 1:
        return Image.asset(
          'assets/images/123.png',
          height: 64,
          width: 64, // Cover the entire width
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
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 77:
        return Image.asset(
          'assets/images/77.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 95:
        return Image.asset(
          'assets/images/95.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 45:
        return Image.asset(
          'assets/images/4548.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 48:
        return Image.asset(
          'assets/images/4548.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 56:
        return Image.asset(
          'assets/images/5657.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 57:
        return Image.asset(
          'assets/images/5657.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 66:
        return Image.asset(
          'assets/images/6667.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 67:
        return Image.asset(
          'assets/images/6667.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 85:
        return Image.asset(
          'assets/images/8586.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 86:
        return Image.asset(
          'assets/images/8586.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 96:
        return Image.asset(
          'assets/images/9699.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 99:
        return Image.asset(
          'assets/images/9699.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 51:
        return Image.asset(
          'assets/images/515355.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 53:
        return Image.asset(
          'assets/images/515355.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 55:
        return Image.asset(
          'assets/images/515355.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 61:
        return Image.asset(
          'assets/images/616365.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 63:
        return Image.asset(
          'assets/images/616365.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 65:
        return Image.asset(
          'assets/images/616365.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 71:
        return Image.asset(
          'assets/images/717375.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 73:
        return Image.asset(
          'assets/images/717375.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 75:
        return Image.asset(
          'assets/images/717375.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 80:
        return Image.asset(
          'assets/images/808182.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 81:
        return Image.asset(
          'assets/images/808182.png',
          height: 64,
          width: 50, // Cover the entire width
          fit: BoxFit.contain,
        );
      case 82:
        return Image.asset(
          'assets/images/808182.png',
          height: 64,
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

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView( // Wrap everything in a ListView
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
              _cityName.isEmpty ? 'Weather Forecast' : _cityName,
              style: GoogleFonts.alata(
                fontSize: 26,
                // fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 20),
          ListView.builder(
            itemCount: _forecastData.length,
            shrinkWrap: true, // Ensure the inner ListView scrolls correctly
            physics: NeverScrollableScrollPhysics(), // Disable outer ListView scrolling
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
                      gradient: RadialGradient(
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
                                style: GoogleFonts.alumniSans(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              Text(
                                date,
                                style: GoogleFonts.archivo(fontSize: 20, color: Colors.white),
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

  // void _showSearchDialog(BuildContext context) {
  //   String newCityName = "";

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Search Weather Forecast'),
  //         content: TextField(
  //           onChanged: (value) {
  //             newCityName = value;
  //           },
  //           decoration: InputDecoration(
  //             hintText: 'Enter city name',
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               _fetchWeatherForecast(newCityName);
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Search'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
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
  final SharedPreferences prefs;

  ProfileScreen({required this.prefs});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _minTemperature = -50.0;
  double _maxTemperature = 70.0;
  String _userName = "";
  String _message = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void fetchUserData() async {
    try {
      // Sanath get Name, mintemp and maxtemp here
      // Replace with your backend API endpoint to fetch user data
      final response = await http.get(Uri.parse('YOUR_BACKEND_API_URL'));

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          _userName = widget.prefs.getString('name') ?? "HackAI";
          _minTemperature = widget.prefs.getDouble('mintemp') ?? -50.0;
          _maxTemperature = widget.prefs.getDouble('maxtemp') ?? 70.0;
        });
      } else {
        print('Failed to fetch user data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void updateTemperatureSettings() async {
    try {
      // Sanath update the new mintemp and maxtemp here
      // Replace with your backend API endpoint to update temperature settings
      if (_minTemperature >= _maxTemperature) {
        setState(() {
          _message = "Error! Minimum Temperature should be lesser";
        });
      } else {
        final response = await http.put(
          Uri.parse('YOUR_BACKEND_API_URL'),
          body: jsonEncode({
            'minTemperature': _minTemperature,
            'maxTemperature': _maxTemperature,
          }),
          headers: {'Content-Type': 'application/json'},
        );

        if (response.statusCode == 200) {
          print('Temperature settings updated successfully.');
        } else {
          print(
              'Failed to update temperature settings: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error: $e');
    }
  }

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
                    // fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 30),

              Column(
                children: [
                  CircleAvatar(
                    radius: 70.0,
                    backgroundColor: Color.fromARGB(255, 196, 196, 196),
                    backgroundImage: AssetImage(
                      'assets/images/profile_image.png',
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Container(
                    height: 80,
                    width: 300,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(255, 175, 222, 255),
                          const Color.fromARGB(255, 6, 123, 208)
                        ],
                      ),
                      borderRadius: BorderRadius.circular(44.0),
                    ),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        // '$_userName',
                        _userName,
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
                      fontSize: 21,
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
                      fontSize: 21,
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
              Text(_message),
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
                      // fontWeight: FontWeight.bold,
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
                  onPressed: () {
                    // Navigate to the main screen (main.dart)
                    // Navigator.pushReplacementNamed(context, '/main');
                    widget.prefs.remove('name');
                    widget.prefs.remove('token');
                    widget.prefs.remove('mintemp');
                    widget.prefs.remove('maxtemp');
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                LandingPage(prefs: widget.prefs)));
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
