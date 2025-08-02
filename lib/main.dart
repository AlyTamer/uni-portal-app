import 'package:flutter/material.dart';
import 'package:uni_portal_app/screens/login_screen.dart';
import 'package:uni_portal_app/screens/dummy_screen.dart';
import 'package:uni_portal_app/screens/mailbox_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UHub',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurpleAccent),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          titleSmall: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}