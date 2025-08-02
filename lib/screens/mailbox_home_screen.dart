import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MailboxHomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const MailboxHomeScreen({super.key, required this.username, required this.password});

  @override
  State<MailboxHomeScreen> createState() => _MailboxScreenState();
}

class _MailboxScreenState extends State<MailboxHomeScreen> {
  late Future<List<Map<String, String>>> futureMessages;
  late Future<String> futureHtml;

  @override
  void initState() {
    super.initState();
    futureHtml = loadInboxHtml();

  }
  Future<String> loadInboxHtml() async {
    const platform = MethodChannel('com.alyelanany.uni_portal_app/owa');
    try {
      final html = await platform.invokeMethod('fetchInboxHtml', {
        'username': widget.username,
        'password': widget.password,
      });
      print('📄 Inbox HTML loaded: ${html.substring(0, 1000)}');

      if (html.contains('Inbox') || html.contains('owaTitle')) {
        print('✅ Login succeeded and loaded mailbox.');
      } else if (html.contains('logon') || html.contains('username')) {
        print('🛑 Login page detected again. Login likely failed.');
      } else {
        print('❓ Unrecognized HTML structure. Need to inspect further.');
      }

      // Preview
      return html;
    } on PlatformException catch (e) {
      print('❌ Native method failed: ${e.message}');
      return 'Error: ${e.message}';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body:FutureBuilder<String>(
      future: futureHtml,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Text(snapshot.data ?? '', style: const TextStyle(color: Colors.white)),
        );
      },
    ),
    );

  }
}