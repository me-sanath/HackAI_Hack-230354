import 'package:cliMate/pages/homepage.dart';
import 'package:cliMate/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'TemperaturePreferencesPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';

class SignUp extends StatelessWidget {
  final FlutterSecureStorage storage;

  SignUp({required this.storage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(
        storage: storage,
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  final FlutterSecureStorage storage;

  SignUpPage({required this.storage});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final Dio dio = Dio();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _userId = ''; //Variable to store the user's ID
  String _message = ''; //Variable to store the informational message

  Future<void> _signUp() async {
    final apiService = ApiService(
        dio); // Create an instance of the ApiService to make API requests.
    final String name =
        _nameController.text; // Get the name from the name input field.
    final String email =
        _emailController.text; // Get the email from the email input field.
    final String password = _passwordController
        .text; // Get the password from the password input field.
    final String confirmPassword = _confirmPasswordController
        .text; // Get the password confirmation from the input field.

    if (password == confirmPassword) {
      try {
        // Attempt to register the user with the provided information.
        final registrationData = await apiService
            .register({'username': name, 'email': email, 'password': password});

        // Write the access token and username to the secure storage.
        await widget.storage
            .write(key: "access_token", value: registrationData.token);
        await widget.storage
            .write(key: "username", value: registrationData.name);

        // Set the user ID and message to indicate successful registration.
        setState(() {
          _userId = registrationData.name;
          _message = 'Registration Done.';
        });

        // Navigate to the TemperaturePreferencesPage with the user ID and storage.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TemperaturePreferencesPage(
                userId: _userId, storage: widget.storage),
          ),
        );
      } catch (e) {
        // Handle the case where registration fails (e.g., email already used) and set the message.
        _message = 'Email already used';
      }
    } else {
      // Set the message to indicate that the entered passwords do not match.
      setState(() {
        _message = 'Passwords do not match.';
        print(_message);
      });
    }
    print(_message); // Print the final message for debugging or feedback.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Disable resizing when the keyboard appears
      body: SingleChildScrollView(
        // Scrollable content
        child: Container(
          height: MediaQuery.of(context).size.height,
          color: const Color.fromARGB(
              255, 240, 249, 255), // Set the background color to light blue
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(
                  right: 40.0, left: 40, top: 10), // Define padding
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.start, // Align content at the top
                children: [
                  SizedBox(height: 30), // Empty space for spacing
                  Container(
                    width: 350,
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 190, 228, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.alata(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 100), // Increased spacing below the title
                  Text(
                    'Welcome to cli-Mate, please Sign Up to continue',
                    style: GoogleFonts.alata(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                      height: 30), // Increased spacing below the description
                  _buildTextField(_nameController,
                      'Name:'), // Custom text input field for Name
                  SizedBox(height: 20), // Space between fields
                  _buildTextField(_emailController,
                      'Email:'), // Custom text input field for Email
                  SizedBox(height: 20), // Space between fields
                  _buildTextField(_passwordController, 'Password:',
                      isPassword: true), // Password input field
                  SizedBox(height: 20), // Space between fields
                  _buildTextField(
                      _confirmPasswordController, 'Confirm Password:',
                      isPassword: true), // Password confirmation input field
                  SizedBox(
                      height: 80), // Increased spacing above the Sign-Up button
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                        Color.fromARGB(255, 92, 187, 255),
                      ),
                      foregroundColor: MaterialStateProperty.all<Color>(
                        Colors.black, // Set the font color to black
                      ),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20.0), // Adjust the radius for all sides
                          side: BorderSide(
                              color: Colors
                                  .black), // Set the border color to black
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical:
                                15.0), // Increase padding for the horizontal direction
                      ),
                    ),
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.alata(
                        fontSize: 20,
                      ),
                    ),
                  ),
                  SizedBox(height: 20), // Space below the Sign-Up button
                  Text(
                    _message, // Display a message (e.g., success or error message)
                    style: GoogleFonts.alata(color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      {bool isPassword = false}) {
    return Container(
      width: 350, // Set the width of the text input container
      decoration: BoxDecoration(
        color: Color.fromARGB(
            255, 190, 228, 255), // Set the background color to light blue
        borderRadius: BorderRadius.circular(
            15.0), // Adjust the radius as needed for rounded corners
        border: Border.all(
          width: 1.0,
          color: Colors.blue, // Set the border color to blue for text fields
        ),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 77, 77, 77).withOpacity(
                0.5), // Add a shadow to the container (black with opacity)
            spreadRadius: 1, // Spread radius of the shadow
            blurRadius: 1, // Blur radius of the shadow
            offset:
                Offset(0, 2), // Offset of the shadow in the x and y direction
          ),
        ],
      ),
      child: TextField(
        controller: controller, // Link the TextField to the provided controller
        obscureText: isPassword, // Enable password mode if required
        style: GoogleFonts.alata(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ), // Define the text style (color and font weight)
        decoration: InputDecoration(
          labelText: labelText, // Set the label text
          labelStyle: TextStyle(color: Colors.black), // Label text color
          border: InputBorder.none, // Remove the default input border
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ), // Set content padding (spacing within the input field)
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
