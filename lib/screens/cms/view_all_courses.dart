import 'package:flutter/material.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  String courseName = '';
  List<ListTile> courses = [
    ListTile(
      title: Text('Course 1'),
      subtitle: Text('Description of Course 1'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 2'),
      subtitle: Text('Description of Course 2'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 3'),
      subtitle: Text('Description of Course 3'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 4'),
      subtitle: Text('Description of Course 4'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 5'),
      subtitle: Text('Description of Course 5'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 6'),
      subtitle: Text('Description of Course 6'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 7'),
      subtitle: Text('Description of Course 7'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 8'),
      subtitle: Text('Description of Course 8'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 9'),
      subtitle: Text('Description of Course 9'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
    ListTile(
      title: Text('Course 10'),
      subtitle: Text('Description of Course 10'),
      leading: Icon(Icons.book, color: Colors.deepPurple),
      trailing: Icon(Icons.download, color: Colors.deepPurple),
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Color.fromRGBO(11, 11, 11, 1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              Container(
                width: 150,
                height: 70,
                child: DrawerHeader(
                  decoration: BoxDecoration(color: Colors.black87),
                  child: Text.rich(
                    TextSpan(
                      children: [
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
                                  Rect.fromLTWH(
                                    0,
                                    0,
                                    bounds.width,
                                    bounds.height,
                                  ),
                                ),
                            child: RichText(
                              text: TextSpan(
                                text: 'Menu',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.home, color: Colors.deepPurple),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Add your logout logic here
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromRGBO(1, 1, 1, 1),
          leading: Builder(
            builder: (context) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [BoxShadow(blurRadius: 10.0, spreadRadius: 2.0)],
              ),
              child: IconButton(
                icon: Icon(Icons.menu, color: Colors.deepPurple),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
          ),
          title: Text.rich(
            TextSpan(
              children: [
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
                        text: 'CMS',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          titleSpacing: 120,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
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
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(65, 65, 65, 1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 70,
                  width: double.infinity,
                  child: Center(
                    child: DropdownMenu(
                      inputDecorationTheme: InputDecorationTheme(
                        filled: true,
                        fillColor: Color.fromRGBO(15, 15, 15, 0.9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                      ),
                      width: MediaQuery.of(context).size.width * 0.9,
                      dropdownMenuEntries: [
                        DropdownMenuEntry(value: 'math', label: 'Math'),
                        DropdownMenuEntry(value: 'physics', label: 'Physics'),
                      ],
                      hintText: 'Select Course',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 45),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
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
                                Rect.fromLTWH(
                                  0,
                                  0,
                                  bounds.width,
                                  bounds.height,
                                ),
                              ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: 'courseName',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.80,
                                height: 5,
                                color: Colors.deepPurpleAccent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView.builder(
                    itemBuilder: (context, idx) {
                      return courses[idx];
                    },
                    itemCount: courses.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
