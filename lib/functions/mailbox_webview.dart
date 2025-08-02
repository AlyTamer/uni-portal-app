import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OwaWebView extends StatefulWidget {
  final String username;
  final String password;
  final void Function(WebViewController)? onControllerReady;

  const OwaWebView({
    super.key,
    required this.username,
    required this.password,
    this.onControllerReady,
  });

  @override
  State<OwaWebView> createState() => _OwaWebViewState();
}

class _OwaWebViewState extends State<OwaWebView> {
  late final WebViewController controller;
  bool injectedLogin = false;
  bool showWebView = false;

  @override
  void initState() {
    super.initState();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) async {
            final isExternal = !request.url.contains('mail.guc.edu.eg');
            if (isExternal) {
              final uri = Uri.parse(request.url);
              if (await canLaunchUrl(uri)) {
                launchUrl(uri, mode: LaunchMode.externalApplication);
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (url) async {
            if (url.contains('auth/logon.aspx') && !injectedLogin) {
              injectedLogin = true;
              await controller.runJavaScript('''
                document.getElementById('username').value = '${widget.username}';
                document.getElementById('password').value = '${widget.password}';
                document.forms[0].submit();
              ''');
            } else if (!url.contains('auth/logon.aspx')) {
              // ✅ Reinjection after login or refresh
              await controller.runJavaScript('''
                (function() {
                  // Disable zoom
                  var meta = document.createElement('meta');
                  meta.name = "viewport";
                  meta.content = "width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no";
                  document.head.appendChild(meta);

                  // Dark layout styling only
                  var style = document.createElement('style');
                  style.innerHTML = `
                    html, body {
                      background-color: #000 !important;
                      color: #fff !important;
                    }

                    .ms-CommandBar, .ms-Button, .ms-List-cell, .ms-ContextualMenu, .ms-ContextualMenu-link,
                    .ms-FocusZone, .ms-Nav, ._3fTR {
                      background-color: #111 !important;
                      color: #fff !important;
                    }

                    button, input, textarea, select {
                      background-color: #111 !important;
                      color: #fff !important;
                      border: 1px solid #9C27B0 !important;
                    }

                    .ms-Icon, ._2n9D, ._2nZk, .ms-Link {
                      color: #9C27B0 !important;
                    }

                    ::-webkit-scrollbar-thumb {
                      background-color: #9C27B0 !important;
                    }

                    /* Don't override inline message colors */
                    ._3fTR * {
                      color: inherit !important;
                    }
                  `;
                  document.head.appendChild(style);

                  // Highlight section headers (e.g., SUNDAY)
                  document.querySelectorAll('[role="heading"], [aria-level="2"]').forEach(el => {
                    el.style.color = "#00BCD4";
                    el.style.fontWeight = "bold";
                  });
                })();
              ''');

              if (!showWebView) {
                setState(() {
                  showWebView = true;
                });
              }
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://mail.guc.edu.eg/owa/'));

    if (widget.onControllerReady != null) {
      widget.onControllerReady!(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (!showWebView)
          const Center(child: CircularProgressIndicator()),
        if (showWebView)
          RefreshIndicator(
            onRefresh: () async => await controller.reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: WebViewWidget(controller: controller),
              ),
            ),
          ),
      ],
    );
  }
}
