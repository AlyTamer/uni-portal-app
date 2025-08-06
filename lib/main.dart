import 'package:flutter/material.dart';
import 'package:uni_portal_app/screens/cms/acitve_course_screen.dart';
import 'package:uni_portal_app/screens/cms/cms_main_screen.dart';
import 'package:uni_portal_app/screens/cms/view_all_courses.dart';
import 'package:uni_portal_app/screens/login_screen.dart';
import 'package:uni_portal_app/screens/schedule_screen.dart';

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
