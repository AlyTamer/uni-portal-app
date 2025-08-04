import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/content_download_tile_widget.dart';

class ActiveCourse extends StatefulWidget {
  final String courseName;
  const ActiveCourse({super.key, required this.courseName});

  @override
  State<ActiveCourse> createState() => _ActiveCourseState();
}

class _ActiveCourseState extends State<ActiveCourse> {
  Widget _gradientTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          colors: [Colors.purple, Colors.pink, Colors.blueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }

  bool willOverflow(String text, double maxWidth, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final codeOnly = RegExp(r'^\|(.*?)\|').firstMatch(widget.courseName)?.group(0) ?? widget.courseName;
    final cleaned = widget.courseName.replaceFirst(RegExp(r'^\|.*?\|\s*'), '');
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
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
                leading: const Icon(Icons.home, color: Colors.deepPurple),
                title: const Text('Home'),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                leading: const Icon(Icons.search, color: Colors.purpleAccent),
                title: const Text('View Previous Courses'),
                onTap: () => Navigator.pop(context),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () => Navigator.pop(context),
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [BoxShadow(blurRadius: 10.0, spreadRadius: 2.0)],
              ),
              child: IconButton(
                icon: const Icon(Icons.menu, color: Colors.deepPurple),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.purple, Colors.pink, Colors.blueAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
            child: Text(
             willOverflow(widget.courseName,MediaQuery.of(context).size.width * 0.6,Theme.of(context).textTheme.titleLarge!.copyWith(fontSize: 17))?codeOnly: cleaned,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 17),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          titleSpacing: 120,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  _gradientTitle("Announcements"),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18.0),
                            gradient: const LinearGradient(
                              colors: [Colors.purpleAccent, Colors.pink, Colors.lightBlue],
                              begin: Alignment.topRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          margin: const EdgeInsets.all(6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.0),
                            color: const Color.fromRGBO(1, 1, 1, 1),
                          ),
                          child: Center(
                            child: Text(
                              "Placeholder Text",
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _gradientTitle("Materials"),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Container(
                      height: 8,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                ]),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, idx) {
                  return DownloadTile(title: (idx + 1).toString());
                },
                childCount: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
