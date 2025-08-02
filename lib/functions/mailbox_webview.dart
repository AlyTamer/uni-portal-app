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
      const css = `
        html, body {
          background-color: #121212 !important;
          color: #e0e0e0 !important;
        }
      `;
      let tries = 0;
      const interval = setInterval(() => {
        if (!document.getElementById('dark-mode-style')) {
          const style = document.createElement('style');
          style.id = 'dark-mode-style';
          style.innerHTML = css;
          document.head.appendChild(style);
        }
        if (++tries > 10) clearInterval(interval);
      }, 500);
    })();
  ''';

    await controller.runJavaScript(js);
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: WebViewWidget(controller: controller),
          ),
        ),
      ),
    );
  }
}
