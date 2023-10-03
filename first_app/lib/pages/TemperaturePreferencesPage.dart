import 'package:first_app/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// If you want to run the page uncomment:
// void main() {
//   runApp(
//     MaterialApp(
//       home: Directionality(
//         textDirection: TextDirection.ltr, // Set the text direction
//         child: TemperaturePreferencesPage(userId: 'poop',),
//       ),
//     ),
//   );
// }

class TemperaturePreferencesPage extends StatefulWidget {
  final String userId;

  TemperaturePreferencesPage({required this.userId});

  @override
  _TemperaturePreferencesPageState createState() =>
      _TemperaturePreferencesPageState();
}

class _TemperaturePreferencesPageState
    extends State<TemperaturePreferencesPage> {
  double _minTemp = -50.0;
  double _maxTemp = 70.0;

  String _message = '';

  Future<void> _saveTemperaturePreferences() async {
    final Map<String, dynamic> tempPreferences = {
      'min_temp': _minTemp,
      'max_temp': _maxTemp,
      'user': widget.userId,
    };

    // Sanath, send data to the backend
    final response = await http.post(
      Uri.parse('http://your-django-api-url/preferences/'), // Replace with your preferences endpoint URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(tempPreferences),
    );

    if (response.statusCode == 200) {
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(userId: widget.userId),
          ),
        );
        _message = 'Preferences saved successfully.';
      });
    } else {
      setState(() {
        _message = 'Failed to save preferences: ${response.body}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Minimum Temperature: ${_minTemp.toStringAsFixed(1)}°C'),
                Slider(
                  value: _minTemp,
                  min: -50.0,
                  max: 70.0,
                  onChanged: (value) {
                    setState(() {
                      _minTemp = value;
                    });
                  },
                ),
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Maximum Temperature: ${_maxTemp.toStringAsFixed(1)}°C'),
                Slider(
                  value: _maxTemp,
                  min: -50.0,
                  max: 70.0,
                  onChanged: (value) {
                    setState(() {
                      _maxTemp = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTemperaturePreferences,
              child: Text('Save Preferences'),
            ),
            SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
