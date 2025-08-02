import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OwaWebView extends StatefulWidget {
  final String username;
  final String password;

  const OwaWebView({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<OwaWebView> createState() => _OwaWebViewState();
}

class _OwaWebViewState extends State<OwaWebView> {
  late final WebViewController controller;
  bool injectedLogin = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          if (url.contains('auth/logon.aspx') && !injectedLogin) {
            injectedLogin = true;
            await controller.runJavaScript('''
              document.getElementById('username').value = '${widget.username}';
              document.getElementById('password').value = '${widget.password}';
              document.forms[0].submit();
            ''');
          }
        },
      ))
      ..loadRequest(Uri.parse(
        'https://mail.guc.edu.eg/owa/',
      ));
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
