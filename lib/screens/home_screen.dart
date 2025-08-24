import 'package:flutter/material.dart';
import 'package:uni_portal_app/screens/cms/view_all_courses.dart';
import 'package:uni_portal_app/screens/grades/transcript_screen.dart';
import 'package:uni_portal_app/screens/grades/view_grade_screen.dart';
import 'package:uni_portal_app/screens/schedule/schedule_screen.dart';
import 'package:uni_portal_app/widgets/custom_drawer_widget.dart';
import 'package:uni_portal_app/widgets/offline_banner_widget.dart';

import '../functions/mailbox/webview_util.dart';
import '../widgets/app_icon_widget.dart';
import 'mailbox_screen.dart';


class HomeScreen extends StatefulWidget {
  final String username;
  final String password;

  const HomeScreen({super.key, required this.username, required this.password});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    String fName = widget.username.split('.').first;
    fName = fName[0].toUpperCase() + fName.substring(1);
    return SafeArea(
      child: OfflineBanner(
        child: Scaffold(
          drawer: CustomDrawerWidget(),
          appBar: AppBar(
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
            titleSpacing: 20,
          ),
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
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(93, 0, 0, 1.0),
                        Color.fromRGBO(94, 14, 121, 1.0),
                        Color.fromRGBO(0, 39, 114, 1.0),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 1.0),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
                                    username: widget.username,
                                    password: widget.password,
                                  ),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.mail,
                              iconName: 'Mail',
                              iconSize: 60,
                              iconColor: Colors.white,
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
                              icon: Icons.calendar_month_rounded,
                              iconName: 'Sched',
                              iconSize: 60,
                              iconColor: Colors.white,
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
                              iconColor: Colors.white,
                              iconSize: 60,
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
                                  builder: (context) => GradeScreen(),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.percent,
                              iconName: 'Grades',
                              iconColor: Colors.white,
                              iconSize: 60,
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
                                  builder: (_) => TranscriptScreen(),
                                ),
                              );
                            },
                            child: InteractiveIcon(
                              icon: Icons.grading_rounded,
                              iconName: 'Transcript',
                              iconColor: Colors.white,
                              iconSize: 60,
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () {},
                            child: InteractiveIcon(
                              icon: Icons.person,
                              iconName: 'Attendance',
                              iconColor: Colors.white,
                              iconSize: 60,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(93, 0, 0, 1.0),
                            Color.fromRGBO(94, 14, 121, 1.0),
                            Color.fromRGBO(0, 39, 114, 1.0),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none_outlined,
                              size: 60,
                              color: Color.fromRGBO(255, 255, 255, 1.0),
                            ),
                            Text(
                              ': 0',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ),

                    Container(
                      height: 100,
                      width: MediaQuery.of(context).size.width / 1.79,

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.0),
                        gradient: LinearGradient(
                          colors: [
                            Color.fromRGBO(0, 19, 94, 1.0),
                            Color.fromRGBO(74, 0, 101, 1.0),
                            Color.fromRGBO(73, 0, 0, 1.0),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.centerLeft,
                        ),
                      ),
                      padding: EdgeInsets.all(5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Center(
                          //TODO implement Dynamic Exam Count
                          child: Text(
                            'Upcoming Exams: 0',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(93, 0, 0, 1.0),
                        Color.fromRGBO(94, 14, 121, 1.0),
                        Color.fromRGBO(0, 39, 114, 1.0),
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.centerLeft,
                    ),
                  ),
                  padding: EdgeInsets.all(5),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 1.0),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //TODO implement dynamic announcements
                          Text(
                            'Announcements',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No new announcements at the moment.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
