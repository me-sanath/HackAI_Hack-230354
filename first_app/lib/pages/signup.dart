import 'package:flutter/material.dart';
import 'TemperaturePreferencesPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _userId = '';
  String _message = '';

  Future<void> _signUp() async {
    final String name = _nameController.text;
    final String email = _emailController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    if (password == confirmPassword) {
      final Map<String, dynamic> userData = {
        'name': name,
        'email': email,
        'password': password,
      };

      final response = await http.post(
        Uri.parse(
            'http://your-django-api-url/register/'), // Replace with your registration endpoint URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        final String receivedUserId = 'user_id_from_django';

        setState(() {
          _userId = receivedUserId;
        });
        setState(() {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TemperaturePreferencesPage(userId: _userId),
            ),
          );
          _message = 'Registration successful.';
        });
      } else {
        setState(() {
          _message = 'Registration failed: ${response.body}';
        });
      }
    } else {
      setState(() {
        _message = 'Passwords do not match.';
        print(_message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(
              255, 240, 249, 255), // Set the background color to light blue
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start, // Changed to start
                children: [
                  SizedBox(height: 30),
                  Container(
                    width: 300,
                    padding: const EdgeInsets.all(16.0),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 190, 228, 255),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 100), // Increased the top spacing
                  Text(
                    'Welcome to cli-Mate, please Sign Up to continue',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                    ),
                  ),
                  SizedBox(
                      height: 40), // Increased spacing below the description
                  _buildTextField(_nameController, 'Name:'),
                  SizedBox(height: 20),
                  _buildTextField(_emailController, 'Email:'),
                  SizedBox(height: 20),
                  _buildTextField(_passwordController, 'Password:',
                      isPassword: true),
                  SizedBox(height: 20),
                  _buildTextField(
                      _confirmPasswordController, 'Confirm Password:',
                      isPassword: true),
                  SizedBox(height: 80),
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
                              30.0), // Adjust the radius for all sides
                          side: BorderSide(
                              color: Colors
                                  .black), // Set the border color to black
                        ),
                      ),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
                        EdgeInsets.symmetric(
                            horizontal: 40.0,
                            vertical:
                                20.0), // Increase padding for the horizontal direction
                      ),
                    ),
                    child: Text('Sign Up'),
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
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 190, 228, 255), // Set the background color
        borderRadius:
            BorderRadius.circular(15.0), // Adjust the radius as needed
        border: Border.all(
          width: 1.0,
          color: Colors.blue, // Set the border color to blue for text fields
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.5), // Shadow color (black with opacity)
            spreadRadius: 2, // Spread radius
            blurRadius: 5, // Blur radius
            offset: Offset(0, 3), // Offset in the x and y direction
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ), // Text color
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color: Colors.black), // Label text color
          border: InputBorder.none, // Remove the default input border
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.0,
            vertical: 10.0,
          ),
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
