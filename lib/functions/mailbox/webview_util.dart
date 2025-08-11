import 'package:webview_flutter/webview_flutter.dart';

Future<void> clearWebViewSession() async {
  final cookieManager = WebViewCookieManager();
  await cookieManager.clearCookies();
  final controller = WebViewController();
  await controller.runJavaScript("window.localStorage.clear();");
}

