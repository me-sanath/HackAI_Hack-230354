import 'package:first_app/pages/login.dart';
import 'package:first_app/pages/signup.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

//Use this to run app
void main() {
  runApp(MyApp());
}

class LocationData {
  final double latitude;
  final double longitude;

  LocationData(this.latitude, this.longitude);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LocationData _locationData = LocationData(
    37.7749, // Replace with your desired latitude
    -122.4194, // Replace with your desired longitude
  );
  String? _placeName;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
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
        print('Place Name: $placeName');
        setState(() {
          _placeName = placeName;
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_isLoading)
              CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    'Current Location: ${_locationData.latitude}, ${_locationData.longitude}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Place Name: ${_placeName ?? "Loading..."}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Handle signup button press
                Navigator.push(
                  context, MaterialPageRoute(builder: (context) => SignUp())
                );
              },
              child: Text('Sign Up'),
            ),
            SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {
                // Handle login button press
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => LoginApp()));
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
