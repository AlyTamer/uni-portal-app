import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/cms_tile_widget.dart';

class CmsHome extends StatelessWidget {
  const CmsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          backgroundColor: Color.fromRGBO(11,11,11,1),
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
                leading: Icon(Icons.home,color: Colors.deepPurple,),
                title: Text('Home'),
                onTap: () {
                  Navigator.pop(context); // Close drawer
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                leading: Icon(Icons.search,color: Colors.purpleAccent,),
                title: Text('View Previous Courses'),
                onTap: () {
                  Navigator.pop(context); // Add your logout logic here
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),

              ListTile(
                leading: Icon(Icons.logout,color: Colors.red,),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context); // Add your logout logic here
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          leading: Builder(
            builder: (context) => Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(blurRadius: 10.0, spreadRadius: 2.0),
                ],
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
            children: [
              const Spacer(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: [
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
                              text: 'Active Courses',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16,
              width:double.infinity),

              ShaderMask(
                shaderCallback: (bounds) =>
                LinearGradient(
                  colors:[
                    Colors.purpleAccent,
                    Colors.pink,
                    Colors.lightBlue,
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.centerLeft,
                ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),

                    color: const Color.fromRGBO(90, 90, 90, 1.0), // base dark tone
                  ),

                  height: 500,
                  width: double.infinity,

                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CmsWidget(title: 'Math 401'),
                        CmsWidget(title: 'CSEN 401'),
                        CmsWidget(title: 'ELCT 404'),
                        CmsWidget(title: 'CSEN 403'),
                        CmsWidget(title: 'SM 401'),
                        CmsWidget(title: 'DE 404'),
                      ],
                    ),
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
