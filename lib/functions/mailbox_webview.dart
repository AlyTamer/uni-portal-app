import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:uni_portal_app/screens/main_screen.dart'; // needed for back override

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
      ..setNavigationDelegate(
        NavigationDelegate(
            onPageFinished: (url) async {
              if (!injectedLogin && url.contains('auth/logon.aspx')) {
                injectedLogin = true;
                await controller.runJavaScript('''
      document.getElementById('username').value = '${widget.username}';
      document.getElementById('password').value = '${widget.password}';
      document.forms[0].submit();
    ''');
              }

              Future.delayed(const Duration(milliseconds: 500), () async {
                await _injectDarkModeCSS();
                await _injectNoZoomMeta();
              });
            },

        ),
      )
      ..loadRequest(Uri.parse('https://mail.guc.edu.eg/owa/'));
  }

  Future<void> _injectDarkModeCSS() async {
    const js = '''
    (function() {
      function applyDarkStyles() {
        const all = document.querySelectorAll('*');
        for (let i = 0; i < all.length; i++) {
          all[i].style.backgroundColor = '#121212';
          all[i].style.color = '#e0e0e0';
        }
      }

      // Apply once now
      applyDarkStyles();

      // Set up observer for future dynamic content
      const observer = new MutationObserver((mutations) => {
        applyDarkStyles();
      });

      observer.observe(document.body, {
        childList: true,
        subtree: true
      });
    })();
  ''';

    // Retry up to 5 times to ensure it's injected during async DOM changes
    for (int i = 0; i < 5; i++) {
      await controller.runJavaScript(js);
      await Future.delayed(const Duration(seconds: 1));
    }
  }



  Future<void> _injectNoZoomMeta() async {
    await controller.runJavaScript('''
      var meta = document.createElement('meta');
      meta.name = 'viewport';
      meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
      document.getElementsByTagName('head')[0].appendChild(meta);
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(
              username: widget.username,
              password: widget.password,
            ),
          ),
        );
        return false;
      },
      child: RefreshIndicator(
        onRefresh: () async {
          await controller.reload();
          // CSS injection will run again via onPageFinished
        },
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
