import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OwaScraper extends StatefulWidget {
  final String username;
  final String password;
  const OwaScraper({super.key, required this.username, required this.password});
  @override _OwaScraperState createState() => _OwaScraperState();
}

class _OwaScraperState extends State<OwaScraper> {
  late final WebViewController controller;
  bool isLoggedIn = false;
  List<MailboxItem> items = [];

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (url) async {
          if (!isLoggedIn && url.contains('/owa/')) {
            isLoggedIn = true;
            _parseInboxViaJS();
          }
        },
      ))
      ..loadRequest(Uri.parse(
        'https://mail.guc.edu.eg/owa/auth/logon.aspx?replaceCurrent=1&url=https%3a%2f%2fmail.guc.edu.eg%2fowa%2f',
      ));
  }

  void injectLoginJS() async {
    await controller.runJavaScript('''
      document.getElementById('username').value = '${widget.username}';
      document.getElementById('password').value = '${widget.password}';
      document.forms[0].submit();
    ''');
  }

  void _parseInboxViaJS() async {
    final js = '''
      (function() {
        const rows = document.querySelectorAll('div[role="row"]');
        const out = [];
        rows.forEach(r => {
          const subj = r.querySelector('[role="gridcell"][data-col="Subject"]');
          const snd = r.querySelector('[data-col="From"]');
          const dt = r.querySelector('[data-col="ReceivedTime"]');
          if (subj && snd && dt) {
            out.push({subject: subj.innerText, sender: snd.innerText, date: dt.innerText});
          }
        });
        return JSON.stringify(out);
      })();
    ''';
    final raw = await controller.runJavaScriptReturningResult(js);
    final list = jsonDecode(raw.toString()) as List;
    setState(() {
      items = list.map((e) => MailboxItem(
          subject: e['subject'], sender: e['sender'], date: e['date'])
      ).toList();
    });
  }

  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inbox')),
      body: items.isEmpty
          ? Column(
        children: [
          Expanded(child: WebViewWidget(controller: controller)),
          ElevatedButton(
            onPressed: injectLoginJS,
            child: Text('Login & Load Inbox'),
          ),
        ],
      )
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, i) {
          final it = items[i];
          return ListTile(
            title: Text(it.subject),
            subtitle: Text('${it.sender} • ${it.date}'),
          );
        },
      ),
    );
  }
}

class MailboxItem {
  final String subject, sender, date;
  MailboxItem({required this.subject, required this.sender, required this.date});
}
