import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/screens/cms/view_all_courses.dart';

import '../screens/about_me_screen.dart';
import '../screens/login_screen.dart';
import '../screens/schedule/other_schedule_screen.dart';
class CustomDrawerWidget extends StatelessWidget {
  const CustomDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return  Drawer(
      backgroundColor: const Color.fromRGBO(11, 11, 11, 1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            width: 150,
            height: 70,
            child: DrawerHeader(
              decoration: const BoxDecoration(color: Colors.black87),
              child: ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.purple, Colors.pink, Colors.blueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.manage_search, color: Colors.deepPurpleAccent),
            title: const Text('Other Schedules'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute (
                  builder:(_)=> OtherSchedules()
              ));
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ListTile(
              leading: const Icon(Icons.search, color: Colors.purpleAccent),
              title: const Text('Previous CMS'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute (
                    builder:(_)=> ViewAllScreen()
                ));
              }
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ListTile(
              leading: const Icon(Icons.gamepad, color: Colors.blueAccent),
              title: const Text('Arcade'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Arcade feature Coming Soon!\nNo Promises ;)'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ListTile(
              leading: const Icon(Icons.calculate_outlined, color: Colors.deepPurpleAccent),
              title: const Text('GPA Calculator'),
              onTap: () {
                //TODO implement Gpa Calculator Capability
              }
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.025),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('About The Dev'),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutMe(),
                ),
              );
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.35),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () async {
              SharedPreferences prefs =
              await SharedPreferences.getInstance();
              await prefs.remove('savedUsername');
              await prefs.remove('savedPassword');

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
