// Import Dio package for making HTTP requests
import 'package:dio/dio.dart';

// Import core Flutter Material library
import 'package:flutter/material.dart';

// Import HTTP package for making HTTP requests (aliased as http)
import 'package:http/http.dart' as http;

// Import Dart's built-in library for working with JSON data
import 'dart:convert';

// Import your custom 'homepage.dart' module or file
import 'homepage.dart';

// Import the Google Fonts package for text styling
import 'package:google_fonts/google_fonts.dart';

// Import Flutter Secure Storage package for secure data storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import your custom 'api_service.dart' module or file
import '../services/api_service.dart';

// If you want to run the page uncomment:
// void main(){
//   final storage = FlutterSecureStorage();
//   runApp(LoginApp(storage: storage,));
// }

// This is the main application widget for the login functionality.
// It initializes the FlutterSecureStorage instance and sets up the initial page to be displayed.
class LoginApp extends StatelessWidget {
  final FlutterSecureStorage storage;

  // Constructor to receive the FlutterSecureStorage instance.
  LoginApp({required this.storage});

  @override
  Widget build(BuildContext context) {
    // MaterialApp widget defines the root of your application.
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable debug banner in the app
      home: LoginPage(
          storage: storage), // Set the LoginPage as the initial screen.
    );
  }
}

class LoginPage extends StatefulWidget {
  final FlutterSecureStorage storage;

  LoginPage({required this.storage});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Create a Dio instance for making HTTP requests.
  final Dio dio = Dio();
// Controllers for the email and password input fields.
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
// A flag to track whether a loading spinner should be shown.
  bool _isLoading = false;
// A message to display to the user, such as login errors.
  String _message = '';
// The user ID retrieved after successful login.
  String _userId = '';

  @override
  void initState() {
    super.initState();
    // Check if an access_token exists when the widget initializes.
    checkAccessToken();
  }

  // This method handles the login process.
  Future<void> _login() async {
    // Create an instance of the ApiService for making API requests.
    final apiService = ApiService(dio);

    // Set the loading flag to true to show a loading spinner.
    setState(() {
      _isLoading = true;
    });

    // Retrieve the email and password from the input fields.
    final email = _emailController.text;
    final password = _passwordController.text;

    // Send a login request with the provided email and password.
    final loginData =
        await apiService.login({'email': email, 'password': password});

    // Store the received access token in secure storage for future use.
    await widget.storage.write(key: 'access_token', value: loginData.token);

    // Extract the user ID from the login response.
    final String receivedUserId = loginData.name;

    // Store the user ID in secure storage for future use.
    await widget.storage.write(key: 'username', value: receivedUserId);

    // Update the local _userId variable and print it.
    print(_userId);

    // Navigate to the Dashboard screen with the user ID.
    setState(() {
      _userId = receivedUserId;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Dashboard(
            userId: _userId,
            storage: widget.storage,
          ),
        ),
      );
      // Display a success message and set isLoading to false.
      _message = 'Login successful.';
      _isLoading = false;
    });
  }

  // This method checks if an access token exists in secure storage.
  Future<void> checkAccessToken() async {
    // Retrieve the access token from secure storage.
    final String? accessToken = await widget.storage.read(key: 'access_token');

    if (accessToken != null) {
      // If an access token exists, navigate to the Dashboard screen.

      // Retrieve the user ID from secure storage.
      final String? receivedUserId = await widget.storage.read(key: 'username');

      // Set the local _userId variable.
      setState(() {
        _userId = receivedUserId!;
      });

      // Navigate to the Dashboard screen with the user ID.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              Dashboard(userId: _userId, storage: widget.storage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: const EdgeInsets.all(45.0),
        color: const Color.fromARGB(255, 240, 249, 255),
        child: Column(
          children: <Widget>[
            Container(
              width: 300,
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 190, 228, 255),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Log In',
                style: GoogleFonts.alata(
                  backgroundColor: const Color.fromARGB(255, 190, 228, 255),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 200,
            ),
            Text(
              'Welcome back, please Log In to continue using cli-Mate:',
              style: GoogleFonts.alata(
                fontSize: 18,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              // Email input container
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 190, 228, 255), // Background color
                borderRadius: BorderRadius.circular(20.0), // Border radius
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 190, 190, 190),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Enter your email:',
                  filled: true,
                  fillColor: Color.fromARGB(255, 190, 228, 255),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              // Password input container
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                    255, 190, 228, 255), // Background color
                borderRadius: BorderRadius.circular(20.0), // Border radius
                boxShadow: [
                  BoxShadow(
                    color: Color.fromARGB(255, 179, 179, 179),
                    spreadRadius: 1,
                    blurRadius: 1,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password:',
                  filled: true,
                  fillColor: const Color.fromARGB(255, 190, 228, 255),
                  border: OutlineInputBorder(
                      borderSide:
                          BorderSide(color: Color.fromARGB(255, 92, 187, 255)),
                      borderRadius: BorderRadius.circular(20.0)),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromARGB(255, 92, 187, 255)),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: OutlinedButton(
                onPressed: _isLoading ? null : _login,
                style: OutlinedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 92, 187, 255),
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  side: BorderSide(color: Colors.black),
                ),
                child: Text(
                  'Log In',
                  style: GoogleFonts.alata(
                    fontSize: 20,
                    color: Colors.black, // Add font weight if needed
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(_isLoading ? 'Logging in...' : _message),
          ],
        ),
      ),
    );
  }
}
