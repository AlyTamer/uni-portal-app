import 'package:flutter/material.dart';
import 'package:uni_portal_app/screens/grades/transcript_screen.dart';
import 'package:uni_portal_app/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UHub',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Lato',
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurpleAccent,
          brightness: Brightness.dark,
          surface: Colors.black,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          titleMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: LoginScreen(),
    );
  }
}
