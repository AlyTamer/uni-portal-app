import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/mailbox_screen.dart';
import '../functions/webview_utils.dart';
import 'login_screen.dart';

class DummyScreen extends StatelessWidget {
  final String username;
  final String password;

  const DummyScreen({
    super.key,
    required this.username,
    required this.password,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedUsername');
    await prefs.remove('savedPassword');
    await clearWebViewSession();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  void _proceed(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullOwaScreen(
          username: username,
          password: password,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Launcher")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text("Logout"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _proceed(context),
              child: const Text("Proceed to Mail"),
            ),
          ],
        ),
      ),
    );
  }
}
