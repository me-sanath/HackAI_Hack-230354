import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';

//to run the current page, uncomment:
// void main() {
//   runApp(Dashboard(userId: 'poop'));
// }

class Dashboard extends StatelessWidget {
  final String userId;

  Dashboard({required this.userId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      HomeScreen(userId: widget.userId, onCityChange: (city) {
      setState(() {
        _currentCity = city;
      });},),
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
            ),
          ),
        ],
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        color: Colors.blue,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        animationDuration: Duration(milliseconds: 300),
        height: 70.0,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.access_time, size: 30),
          Icon(Icons.person, size: 30),
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
    });
    widget.onCityChange(cityName);
  } else {
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
      appBar: AppBar(
        title: Text(_cityName.isEmpty ? 'Weather App' : _cityName),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Temperature: $_temperature °C'),
            Text('Humidity: $_humidity %'),
            Text('Wind Speed: $_windSpeed m/s'),
          ],
        ),
      ),
    );
  }

  void _showSearchDialog(BuildContext context) {
    String newCityName = "";

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
          ],
        );
      },
    );
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
        description: item['description'],
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
            trailing: Text(forecast.description),
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
  final String description;

  WeatherForecast({
    required this.date,
    required this.minTemperature,
    required this.maxTemperature,
    required this.description,
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

