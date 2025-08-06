import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/cms/view_all_courses.dart';
import 'package:uni_portal_app/screens/login_screen.dart';
import 'package:uni_portal_app/screens/schedule_screen.dart';
import '../functions/mailbox/webview_util.dart';
import '../widgets/app_icon_widget.dart';
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
                    shaderCallback: (bounds) => LinearGradient(
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
              Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
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
                        color: Color.fromRGBO(65, 65, 65, 1.0),
                      ),

                    ),
                  ),
                  Positioned(
                    top: 25,
                    left: 10,
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () async {
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
                              iconSize: 60,
                              iconColor: Colors.white54,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScheduleScreen(),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.list_alt_rounded,
                              iconName: 'Sched',
                              iconSize: 60,
                              iconColor: Colors.white54,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewAllScreen(),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.content_paste,
                              iconName: 'CMS',
                              iconColor: Colors.white54,
                              iconSize: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left:10,
                    top:130,
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Row(
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {},
                            child: InteractiveIcon(
                              icon: Icons.percent,
                              iconName: 'Grades',
                              iconColor: Colors.white54,
                              iconSize: 60,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
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
                              icon: Icons.calendar_month_rounded,
                              iconName: 'Exams',
                              iconColor: Colors.white54,
                              iconSize: 60,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
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
                              iconColor: Colors.white54,
                              iconSize: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Stack(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
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
                      height: 400,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        color: Color.fromRGBO(65, 65, 65, 1.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: const Text(
                      "PLACEHOLDER\nRECENT NOTIS\nSCROLL LIST",
                      style: TextStyle(fontSize: 50),
                    ),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
