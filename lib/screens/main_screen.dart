import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/login_screen.dart';

import '../functions/webview_util.dart';
import 'app_icon_widget.dart';
import 'mailbox_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String password;
  const HomeScreen({super.key, required this.username, required this.password});

  @override
  Widget build(BuildContext context) {
    String fName = username.split('.').first;
    fName = fName[0].toUpperCase() + fName.substring(1);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.person),
          title: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Welcome, ',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                WidgetSpan(
                  child: ShaderMask(
                    shaderCallback: (bounds) =>
                        LinearGradient(
                          colors: [
                            Colors.purple,
                            Colors.pink,
                            Colors.blueAccent,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                        ),
                    child: RichText(
                      text: TextSpan(
                        text: fName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          titleSpacing: 0.7,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Spacer(),
              ShaderMask(
                shaderCallback: (bounds) =>
                    LinearGradient(
                      colors: [
                        Colors.purpleAccent,
                        Colors.pink,
                        Colors.lightBlue,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.centerLeft,
                    ).createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                child: Container(
                  height: 270,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    color: Color.fromRGBO(30, 30, 30, 1.0),
                  ),
                  child: Column(
                    children: [
                      const Spacer(flex:2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () async {
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
                            },
                            child: InteractiveIcon(
                              icon: Icons.mail,
                              iconName: 'Mail',
                              iconColor: Colors.white,
                              iconSize: 60,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: InteractiveIcon(
                              icon: Icons.list_alt_rounded,
                              iconName: 'Sched',
                              iconSize: 60,
                              iconColor: Colors.white,
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () async {
                              SharedPreferences prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.remove('savedUsername');
                              await prefs.remove('savedPassword');
                              await clearWebViewSession();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LoginScreen(),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.logout,
                              iconName: 'Logout',
                              iconColor: Colors.red,
                              iconSize: 60,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(flex: 3),
                    ],
                  ),
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
                  child: const Text(
                    "PLACEHOLDER\nRECENT NOTIS\nSCROLL LIST",
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
