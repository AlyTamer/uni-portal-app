import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../functions/mailbox_webview.dart';
class FullOwaScreen extends StatefulWidget {
  final String username;
  final String password;

  const FullOwaScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<FullOwaScreen> createState() => _FullOwaScreenState();
}

class _FullOwaScreenState extends State<FullOwaScreen> {
  WebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop && _controller != null && await _controller!.canGoBack()) {
          _controller!.goBack();
        }
        // If you want to allow app to exit after reaching first page:
        // else if (!didPop) Navigator.of(context).pop();
      },
      child: Scaffold(
        body: SafeArea(
          child: OwaWebView(
            username: widget.username,
            password: widget.password,
            onControllerReady: (controller) {
              _controller = controller;
            },
          ),
        ),
      ),
    );
  }
}
