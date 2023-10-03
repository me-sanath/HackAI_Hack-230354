import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'homepage.dart';

// If you want to run the page uncomment:
// void main(){
//   runApp(LoginApp());
// }

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      body: Padding(
        padding: const EdgeInsets.all(35.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Enter your email: '),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Enter your password: '),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _login,
              child: Text('Login'),
            ),
            SizedBox(height: 20),
            Text(_isLoading ? 'Logging in...' : _message),
          ],
        ),
      ),
    );
  }
}
