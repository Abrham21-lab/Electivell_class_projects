// main.dart
import 'package:flutter/material.dart';
import 'page/login.dart'; // Import your login page

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login & Order App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: LoginPage(), // Start with login page
    );
  }
}
