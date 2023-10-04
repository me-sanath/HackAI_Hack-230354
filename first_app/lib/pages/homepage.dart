import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

//to run the current page, uncomment:
void main() {
  runApp(Dashboard(userId: 'poop'));
}

class Dashboard extends StatelessWidget {
  final String userId;

  Dashboard({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BottomNavigationExample(userId: userId),
    );
  }
}

class BottomNavigationExample extends StatefulWidget {
  final String userId;

  BottomNavigationExample({required this.userId});

  @override
  _BottomNavigationExampleState createState() =>
      _BottomNavigationExampleState();
}

class _BottomNavigationExampleState extends State<BottomNavigationExample> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  List<Widget> _screens = [];
  String _currentCity = "";

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        userId: widget.userId,
        onCityChange: (city) {
          setState(() {
            _currentCity = city;
          });
        },
      ),
      ForecastScreen(userId: widget.userId, cityName: _currentCity),
      ProfileScreen(userId: widget.userId),
    ];
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
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // Satwik your stuff should be here
                // Handle microphone button tap
                // Add your microphone functionality here
              },
              child: Icon(Icons.mic),
              backgroundColor: Color.fromARGB(255, 92, 187, 255),
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
  final String userId;
  final Function(String) onCityChange; // Add this callback

  HomeScreen({required this.userId, required this.onCityChange});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _cityName = "";
  double _temperature = 0.0;
  double _humidity = 0.0;
  double _windSpeed = 0.0;
  int _code = 0;
  Image _image =
      Image.asset('assets/images/95.png', height: 200, fit: BoxFit.contain);
  String _formattedDate = DateFormat('E, dd MMM').format(DateTime.now());
  String _message = '';

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
      setState(() {
        _cityName = cityName!;
      });
      _fetchWeatherData(cityName!);
    }
  }

  Future<void> _fetchWeatherData(String cityName) async {
    setState(() {
      _cityName = cityName;
      widget.onCityChange(cityName);
    });
    final response = await http.get(
      Uri.parse(
        // Sanath, Send the stuff here
        'http://your-django-api-url/weather?city=$cityName', // Replace with your weather API URL
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _cityName = cityName;
        _temperature = data['temperature'];
        _humidity = data['humidity'];
        _windSpeed = data['wind_speed'];
        _code = data['weathercode'];
        _image = getImageForCode(_code);
      });
      widget.onCityChange(cityName);
    } else {
      setState(() {
        _message = "Location not found!";
      });
      _showSearchDialog(context, _message);
      print('Failed to fetch weather data: ${response.statusCode}');
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
                    width: 350,
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
                        SizedBox(width: 15), // Add some spacing
                        Text(
                          _cityName.isEmpty ? 'Weather App' : _cityName,
                          style: GoogleFonts.alata(
                            backgroundColor:
                                const Color.fromARGB(255, 190, 228, 255),
                            fontSize: 24,
                          ),
                        ),
                        SizedBox(width: 25), // Add some spacing
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
                left: 40,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        _temperature.toString() + '°',
                        style: GoogleFonts.alumniSans(
                          fontSize: 150,
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
                top: 240, // Adjust the position as needed
                left: 0,
                right: 0,
                child: _image,
              ),
              // Content (temperature) below the container
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 +
                    20, // Position below the container
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
                top: MediaQuery.of(context).size.height * 0.5 + 140,
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
                top: MediaQuery.of(context).size.height * 0.5 +
                    140, // Position below the container
                left: 20,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(
                          Icons.water,
                          size: 40,
                          color: Colors.white,
                        ), // Humidity icon
                        SizedBox(width: 10), // Add some spacing
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
                      ]) // Add more content here
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).size.height * 0.5 +
                    140, // Position below the container
                left: 180,
                right: 0,
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.speed,
                            size: 40,
                            color: Colors.white,
                          ), // Wind speed icon
                          SizedBox(width: 10), // Add some spacing
                          Column(
                            children: [
                              Text(
                                _windSpeed.toString() +
                                    'km/h', // Replace with actual wind speed value
                                style: GoogleFonts.alata(
                                  fontSize: 20,
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
                      // Add more content here
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
                _fetchWeatherData(newCityName);
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
  final String userId;
  final String cityName;

  ForecastScreen({required this.userId, required this.cityName});

  @override
  _ForecastScreenState createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  String _cityName = "";
  List<WeatherForecast> _forecastData = [];

  @override
  void initState() {
    super.initState();
    _cityName = widget.cityName;
    _fetchWeatherForecast(_cityName);
  }

  Future<void> _fetchWeatherForecast(String cityName) async {
    setState(() {
      _cityName = cityName;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_cityName.isEmpty ? 'Weather Forecast' : _cityName),
      ),
      body: ListView.builder(
        itemCount: _forecastData.length,
        itemBuilder: (context, index) {
          final forecast = _forecastData[index];
          final date = DateFormat('EEE, MMM d').format(forecast.date);

          return ListTile(
            title: Text(date),
            subtitle: Text(
                'Min: ${forecast.minTemperature}°C | Max: ${forecast.maxTemperature}°C'),
            trailing: Text(forecast.code),
          );
        },
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
  final String code;

  WeatherForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.code,
  });
}

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  double _minTemperature = -50.0;
  double _maxTemperature = 70.0;
  String _userName = "";

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
          _userName = userData['name'] ?? '';
          _minTemperature = userData['minTemperature'] ?? -50.0;
          _maxTemperature = userData['maxTemperature'] ?? 70.0;
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
        print('Failed to update temperature settings: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Name: $_userName'),
              SizedBox(height: 16.0),
              Text('Minimum Temperature: $_minTemperature °C'),
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
              Text('Maximum Temperature: $_maxTemperature °C'),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  updateTemperatureSettings();
                },
                child: Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
