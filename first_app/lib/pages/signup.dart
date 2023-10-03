import 'package:flutter/material.dart';
import 'TemperaturePreferencesPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// If you want to run the page uncomment:
// void main(){
//   runApp(SignUp());
// }

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

      // Sanath send the data to django
      final response = await http.post(
        Uri.parse(
            'http://your-django-api-url/register/'), // Replace with your registration endpoint URL
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(userData),
      );

      if (response.statusCode == 200) {
        // Sanath, successful registration, handle the response accordingly
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
        // Sanath, registration failed, handle the error response
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Confirm Password'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
          ],
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
