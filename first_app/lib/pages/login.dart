import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';

// If you want to run the page uncomment:
// void main(){
//   runApp(LoginApp());
// }

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  String _userId = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text;
    final password = _passwordController.text;

    final response = await http.post(
      //Sanath
      Uri.parse(
          'http://your-django-api-url/login/'), // Replace with your actual login endpoint URL
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      // Sanath, successful registration, handle the response accordingly
      //I have named the token as userid everywhere, if u modify the name the entirity might get fucked. So try to keep the name of the token as user id
      final String receivedUserId = 'user_id_from_django';

      setState(() {
        _userId = receivedUserId;
      });
      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(userId: _userId),
          ),
        );
        _message = 'Registration successful.';
      });
      _message = 'Login successful';
    } else {
      // Login failed, handle the error response
      _message = 'Invalid email or password';
    }

    setState(() {
      _isLoading = false;
    });
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
