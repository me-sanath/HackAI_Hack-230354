// Import necessary packages and libraries
import 'package:cliMate/pages/homepage.dart'; // Import the homepage page
import 'package:flutter/material.dart'; // Flutter's material package
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // For secure storage
import 'package:google_fonts/google_fonts.dart'; // Google Fonts for text styling
import 'package:http/http.dart' as http; // HTTP requests
import 'dart:convert'; // JSON decoding and encoding
import '../services/api_service.dart'; // Import API service
import 'package:dio/dio.dart'; // Dio for making HTTP requests
import 'package:firebase_messaging/firebase_messaging.dart'; // Firebase Cloud Messaging (FCM)

// If you want to run the page uncomment:
void main() {
  final storage = FlutterSecureStorage();
  runApp(
    MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr, // Set the text direction
        child: TemperaturePreferencesPage(
          userId: 'test',
          storage: storage,
        ),
      ),
    ),
  );
}

class TemperaturePreferencesPage extends StatefulWidget {
  final String userId;
  final FlutterSecureStorage storage;

  TemperaturePreferencesPage({required this.userId, required this.storage});

  @override
  _TemperaturePreferencesPageState createState() =>
      _TemperaturePreferencesPageState();
}

class _TemperaturePreferencesPageState
    extends State<TemperaturePreferencesPage> {
  final Dio dio = Dio();
  double _minTemp = -50.0;
  double _maxTemp = 70.0;
  String _message = '';
  Color _messageColor = Colors.black;
  TextStyle _messageTextStyle = GoogleFonts.alata(
    fontSize: 16,
    color: Colors.red, // Set text color to red for error
  );

// Function to save temperature preferences
  Future<void> _saveTemperaturePreferences() async {
    final apiService = ApiService(dio);

    // Check if the minimum temperature is greater than or equal to the maximum temperature
    if (_minTemp >= _maxTemp) {
      setState(() {
        _message = 'Error, Minimum Temperature should be lesser';
        _messageColor = Colors.red;
        _messageTextStyle = GoogleFonts.alata(
          fontSize: 16,
          color: Colors.red, // Set text color to red for error
        ); // Set text color to red for error
      });
    } else {
      // Retrieve the access token from storage
      String? token = await widget.storage.read(key: 'access_token');

      // Prepare the request body with minimum and maximum temperature values
      final body = {
        "min_temperature": _minTemp,
        "max_temperature": _maxTemp,
      };

      try {
        // Send an API request to set temperature preferences with the access token
        await apiService.setTemperaturePreferences('Token $token', body);

        // Update the message to indicate successful preferences saving
        setState(() {
          _message = 'Preferences saved successfully.';
          _messageColor = Colors.green;
          _messageTextStyle = GoogleFonts.alata(
            fontSize: 16,
            color: Colors.green, // Set text color to red for error
          );
        });

        // Update stored minimum and maximum temperature values
        widget.storage.write(key: 'mintemp', value: _minTemp.toString());
        widget.storage.write(key: 'maxtemp', value: _maxTemp.toString());
      } catch (e) {
        // Handle the case where saving preferences fails and update the message
        setState(() {
          _message = 'Failed to save preferences: $e';
          _messageColor = Colors.red;
          _messageTextStyle = GoogleFonts.alata(
            fontSize: 16,
            color: Colors.red, // Set text color to red for error
          );
        });
      }

      // Navigate to the Dashboard screen
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(
              userId: widget.userId,
              storage: widget.storage,
            ),
          ),
        );
        _message = 'Preferences saved successfully.';
      });
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

              // Title Container
              Container(
                width: 350,
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 190, 228, 255),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Settings',
                  style: GoogleFonts.alata(
                    fontSize: 26,
                  ),
                ),
              ),
              SizedBox(height: 30),

              // Temperature Sliders
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Minimum Temperature Slider
                  SizedBox(height: 180.0),
                  Text(
                    'Minimum Temperature: $_minTemp °C',
                    style: GoogleFonts.alata(
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: _minTemp,
                    onChanged: (value) {
                      setState(() {
                        _minTemp = value;
                      });
                    },
                    min: -50.0,
                    max: 70.0,
                    divisions: 120,
                    label: '$_minTemp °C',
                  ),
                  SizedBox(height: 16.0),

                  // Maximum Temperature Slider
                  SizedBox(height: 16.0),
                  Text(
                    'Maximum Temperature: $_maxTemp °C',
                    style: GoogleFonts.alata(
                      fontSize: 18,
                    ),
                  ),
                  Slider(
                    value: _maxTemp,
                    onChanged: (value) {
                      setState(() {
                        _maxTemp = value;
                      });
                    },
                    min: -50.0,
                    max: 70.0,
                    divisions: 120,
                    label: '$_maxTemp °C',
                  ),
                ],
              ),

              // Save Settings Button
              SizedBox(height: 50.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                  ),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _saveTemperaturePreferences();
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

              // Display the message below the button
              SizedBox(height: 20.0), // Add some spacing
              Text(
                _message,
                style: _messageTextStyle, // Use the TextStyle for message
              ),
            ],
          ),
        ),
      ),
    );
  }
}
