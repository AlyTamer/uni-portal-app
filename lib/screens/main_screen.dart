import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/login_screen.dart';

import '../functions/webview_util.dart';
import 'mailbox_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String password;
  const HomeScreen({super.key,
  required this.username,
  required this.password});

  @override
  Widget build(BuildContext context) {
    String fName= username.split('.').first;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.person),
          title:Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome, ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                WidgetSpan(
                  child: ShaderMask(shaderCallback: (bounds) =>
                      LinearGradient(colors: [Colors.purple, Colors.pink,Colors.blueAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: RichText(text: TextSpan(text:fName,
                      style: Theme.of(context).textTheme.titleLarge
                      ),
                    ),
                    ),
                  ),

              ],
            ),
          ),
          titleSpacing: 0.7,
        )
        ,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              Container(
                height: 270,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Color.fromRGBO(30, 30, 30, 1.0),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 16.0,),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                          child: Text("Actions",style: Theme.of(context).textTheme.titleLarge,)),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(onPressed: () async {
                          await clearWebViewSession();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullOwaScreen(
                                username: username,
                                password: password,
                              ),
                            ),
                          );
                        }, icon: Icon(Icons.mail,
                        size:100,color: Colors.blueAccent,)),
                        IconButton(onPressed: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          await prefs.remove('savedUsername');
                          await prefs.remove('savedPassword');
                          await clearWebViewSession();
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                          }, icon: Icon(Icons.logout,
                        size: 90,color: Colors.red,))
                      ],
                    ),
                    const Spacer(flex:3),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                height: 400,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Color.fromRGBO(30, 30, 30, 1.0),
                ),
                child: Center(
                    child: const Text("PLACEHOLDER\nRECENT NOTIS\nSCROLL LIST",
                    style: TextStyle(fontSize: 50),)),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
