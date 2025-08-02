import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/dummy_screen.dart';
import 'package:uni_portal_app/screens/mailbox_screen.dart';

import '../functions/webview_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? usernameError;
  String? passwordError;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String username;
  late String password;
  bool hasCheckedPrefs = false;

  bool validateInput() {
    final inputUsername = _usernameController.text.trim().toLowerCase();
    final inputPassword = _passwordController.text;
    usernameError = null;
    passwordError = null;

    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        usernameError = "Username cannot be empty.";
        passwordError = "Password cannot be empty.";
      });
      return false;
    }

    if (!inputUsername.contains('.') || !RegExp(r"^[a-zA-Z.-]+$").hasMatch(inputUsername)) {
      setState(() {
        usernameError = "Invalid Username Format.";
      });
      return false;
    }

    username = inputUsername;
    password = inputPassword;
    return true;
  }

  void navigateToDummy(String user, String pass) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => DummyScreen(username: user, password: pass),
      ),
          (route) => false,
    );
  }

  Future<void> tryLoginAndFetchInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUsername', username);
      await prefs.setString('savedPassword', password);

      await clearWebViewSession(); // ✅ ensure fresh login

      if (!mounted) return;
      navigateToDummy(username, password);
    } catch (e) {
      print('Login or navigation failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!hasCheckedPrefs) {
      hasCheckedPrefs = true;
      _checkSavedLogin();
    }
  }

  void _checkSavedLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('savedUsername') ?? "NO_USERNAME";
    final savedPassword = prefs.getString('savedPassword') ?? "NO_PASSWORD";

    if (savedUsername != "NO_USERNAME" && savedPassword != "NO_PASSWORD") {
      if (!mounted) return;
      navigateToDummy(savedUsername, savedPassword);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
            Center(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.purple, Colors.pink],
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: const Text(
                  'UHub',
                  style: TextStyle(color: Colors.white, fontSize: 140, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter Your Username', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                errorText: usernameError,
                hintText: 'Enter Your Username',
                enabledBorder: _defaultBorder(),
                focusedBorder: _focusBorder(),
                errorBorder: _errorBorder(),
                focusedErrorBorder: _errorBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Enter Your Password', style: Theme.of(context).textTheme.titleMedium),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                errorText: passwordError,
                hintText: 'Enter Your Password',
                enabledBorder: _defaultBorder(),
                focusedBorder: _focusBorder(),
                errorBorder: _errorBorder(),
                focusedErrorBorder: _errorBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  if (validateInput()) {
                    tryLoginAndFetchInbox();
                  }
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(213, 111, 172, 1.0),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color.fromRGBO(50, 28, 89, 1.0),
                    title: Text("Check These Things!", style: Theme.of(context).textTheme.titleLarge),
                    content: const Text(
                      "1- Make sure you have a stable internet connection.\n"
                          "2- Ensure your username and password are correct.\n"
                          "3- If you forgot your password, use the 'Forgot Password' option.",
                      style: TextStyle(fontSize: 22),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
                );
              },
              child: const Text(
                "Trouble Logging In?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _defaultBorder() => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
    borderSide: BorderSide(color: Color.fromRGBO(213, 111, 172, 1.0), width: 2.0),
  );

  OutlineInputBorder _focusBorder() => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
    borderSide: BorderSide(color: Colors.purple, width: 2.0),
  );

  OutlineInputBorder _errorBorder() => const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(16.0)),
    borderSide: BorderSide(color: Colors.red, width: 2.0),
  );
}
