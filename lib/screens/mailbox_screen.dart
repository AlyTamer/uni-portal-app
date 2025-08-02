import 'package:flutter/material.dart';
import 'package:uni_portal_app/functions/mailbox_webview.dart';

class FullOwaScreen extends StatelessWidget {
  final String username;
  final String password;

  const FullOwaScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  SafeArea(
        child: OwaWebView(
          username: username,
          password: password,
        ),
      ),
    );
  }
}
