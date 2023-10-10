import 'dart:convert';
import 'package:cliMate/api/firebase_api.dart';
import 'package:cliMate/firebase_options.dart';
import 'package:dio/dio.dart';
import 'package:cliMate/pages/homepage.dart';
import 'package:cliMate/pages/login.dart';
import 'package:cliMate/pages/signup.dart';
import 'package:cliMate/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';

//Use this to run app
void main() async{
  final storage =  FlutterSecureStorage();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseApi(storage: storage).initNotification();
  runApp(MyApp(storage: storage,));
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData(this.latitude, this.longitude);
}

class MyApp extends StatelessWidget {
  final FlutterSecureStorage storage;

  MyApp({required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(storage: storage,),
    );
  }
}

class LandingPage extends StatefulWidget {
  final FlutterSecureStorage storage;
  LandingPage ({ required this.storage});
  
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final Dio dio = Dio();
  String _userId = '';
  Future<void> checkAccessToken() async {
    final String? accessToken = await widget.storage.read(key: 'access_token');
    if (accessToken != null) {
      // Token exists, navigate to the Dashboard
      final String? receivedUserId = await widget.storage.read(key: 'username');
      setState(() {
        _userId = receivedUserId!;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(userId: _userId, storage: widget.storage),
        ),
      );
    }
  }
  LocationData _locationData = LocationData(
    37.7749, // Replace with your desired latitude
    -122.4194, // Replace with your desired longitude
  );
  String? _placeName;
  bool _isLoading = false;
  double _temperature = 0.0;
  double _code = 0;
  Image _image =
      Image.asset('assets/images/95.png', height: 220, fit: BoxFit.contain);
  String _formattedDate = DateFormat('E, dd MMM').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    checkAccessToken();
    _initLocation();
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


  Future<void> _initLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _locationData = LocationData(position.latitude, position.longitude);
      });

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placeName = placemarks[0].subAdministrativeArea;
        final apiService = ApiService(dio);
        String? token = await widget.storage.read(key: 'access_token');
        final weatherData = await apiService.getDashboardData('Token $token', {'latitude':position.latitude,'longitude':position.longitude});
        setState(() {
          _placeName = placeName;
          _temperature = weatherData.temperature;
          _code = weatherData.weathercode;
          _image = getImageForCode(_code.toInt());
          _isLoading = false;
        });
      } else {
        print('Location name not found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromARGB(255, 175, 222, 255),
              Color.fromARGB(255, 0, 149, 255),
            ],
          ),
        ),
        child: Stack(children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.45,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(44),
              child: Container(
                color: Color.fromARGB(255, 240, 249, 255),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(30.0),
            child: Stack(
              children: [
                // Background Container for the top 50% of the screen
                Positioned(
                  top: 0, // Adjust the position to cover the entire screen
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 206, 234, 255),
                      borderRadius:
                          BorderRadius.circular(20), // Add border radius
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 32,
                            ),
                            SizedBox(width: 15),
                            Text(
                              _placeName == null ? 'Weather App' : _placeName!,
                              style: GoogleFonts.alata(
                                backgroundColor:
                                    const Color.fromARGB(255, 206, 234, 255),
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                        // Add more content here if needed
                      ],
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
                  top: 460,
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
                  top: 570,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignUp(storage: widget.storage),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 92, 187, 255),
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(color: Colors.black),
                        ),
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.alata(
                            fontSize: 25,
                            color: Colors.black, // Add font weight if needed
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 630,
                  left: 0,
                  right: 0,
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginApp(storage: widget.storage),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          side: BorderSide(
                              color: Color.fromARGB(0, 240, 249, 255)),
                        ),
                        child: Text(
                          'Log In',
                          style: GoogleFonts.alata(
                            fontSize: 25,
                            color: Color.fromARGB(
                                255, 0, 149, 255), // Add font weight if needed
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}
