import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'homepage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart'; 

// If you want to run the page uncomment:
// void main(){
//   final storage = FlutterSecureStorage();
//   runApp(LoginApp(storage: storage,));
// }

class LoginApp extends StatelessWidget {
   final FlutterSecureStorage storage;

  LoginApp({required this.storage});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(storage: storage),
    );
  }
}

class LoginPage extends StatefulWidget {
  final FlutterSecureStorage storage;
  
  LoginPage({required this.storage});
  @override
  LoginPageState createState() => LoginPageState(prefs: prefs);
}

class _LoginPageState extends State<LoginPage> {
  final Dio dio = Dio();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _message = '';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    checkAccessToken(); // Check if access_token exists when the widget initializes
  }

  Future<void> _login() async {
    final apiService = ApiService(dio);
    setState(() {
      _isLoading = true;
    });
    final email = _emailController.text;
    final password = _passwordController.text;

    final loginData = await apiService.login({'email':email,'password':password});
    await widget.storage.write(key: 'access_token', value: loginData.token);
    final String receivedUserId = loginData.name;
    await widget.storage.write(key: 'username', value: receivedUserId);
    setState(() {
      _userId = receivedUserId;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Dashboard(userId: _userId,storage: widget.storage,),
          ),
        );
        _message = 'Login successful.';
        _isLoading = false;
      });
  }
    

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
