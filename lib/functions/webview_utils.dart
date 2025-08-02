import 'dart:io';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> clearWebViewSession() async {
  final cookieManager = WebViewCookieManager();
  await cookieManager.clearCookies();
}