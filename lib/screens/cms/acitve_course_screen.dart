import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/functions/cms/cms_web_service.dart';
import 'package:uni_portal_app/widgets/content_download_tile_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';
import 'package:html/dom.dart' as dom; // <-- add this
import '../login_screen.dart';

class ActiveCourse extends StatefulWidget {
  final String courseName;
  final String courseUrl;
  const ActiveCourse({super.key,
    required this.courseName,
    required this.courseUrl});

  @override
  State<ActiveCourse> createState() => _ActiveCourseState();
}

class _ActiveCourseState extends State<ActiveCourse> {
List<String> allAnnouncements = [];
List<Map<String, String>> downloadableMaterials = [];
bool isLoading = true;
bool showAll= false;
  @override
  initState() {
    super.initState();
    _loadData();

  }
Future<void> _loadData() async {
  final cms = CmsService();

  final html = await cms.fetchCourseHtml(widget.courseUrl);
  final doc = parse(html);

  // ===== Parse announcements =====
  final annContainer = doc.querySelector('#ContentPlaceHolderright_ContentPlaceHoldercontent_desc');
  final anns = annContainer != null
      ? annContainer.text
      .split('\n')
      .map<String>((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList()
      : <String>[];

  // ===== Parse downloadable materials =====
  final contentBlocks = doc.querySelectorAll('div[id^="content"]');
  final List<Map<String, String>> materials = [];

  for (final block in contentBlocks) {
    // Get display title from <strong>
    final strongElement = block.querySelector('strong');
    if (strongElement == null) continue;

    String filename = strongElement.text.trim();

    // Remove course code prefix
    filename = filename.replaceFirst(RegExp(r'^\(\|.*?\|\)\s*'), '').trim();
    // Remove number prefix like "1 - "
    filename = filename.replaceFirst(RegExp(r'^\d+\s*-\s*'), '').trim();

    // Get href from the download link in the next section
    final linkElement = block.nextElementSibling
        ?.nextElementSibling
        ?.querySelector('a#download');
    final href = linkElement?.attributes['href']?.trim() ?? '';

    // Skip videos
    if (filename.toLowerCase().endsWith('.mp4') ||
        filename.toLowerCase().endsWith('.m4v')) {
      continue;
    }

    // Add valid items
    if (filename.isNotEmpty && href.isNotEmpty) {
      materials.add({
        'title': filename,
        'href': href,
      });
    }
  }

  setState(() {
    allAnnouncements = anns;
    downloadableMaterials = materials;
    isLoading = false;
  });
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
      child: Center(
        child: isLoading? CircularProgressIndicator():
        Scaffold(
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
                  onTap: () => Navigator.popUntil(context, (route) => route.isFirst),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ListTile(
                  leading: const Icon(Icons.search, color: Colors.purpleAccent),
                  title: const Text('View All Courses'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.025),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout'),
                  onTap: ()async {
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
            title: GradientTitle(size: 18,text:
             codeOnly,

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GradientTitle(text: "Announcements",size:30),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                showAll = !showAll;
                              });
                            },
                            child: Text(
                              showAll ? "Show Less" : "Show More",
                              style: TextStyle(color: Colors.blueAccent),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: showAll ? MediaQuery.of(context).size.height - kToolbarHeight - 32: 200,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18.0),
                              gradient:  LinearGradient(
                                colors: [Color.fromRGBO(104, 24, 131, 1.0), Color.fromRGBO(
                                    113, 0, 0, 1.0), Color.fromRGBO(
                                    0, 49, 124, 1.0)],
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
                            child: allAnnouncements.isEmpty
                                ? Center(child: Text("No Announcements", style : Theme.of(context).textTheme.titleLarge))
                                : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                physics: showAll ? AlwaysScrollableScrollPhysics() : NeverScrollableScrollPhysics(),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: (showAll ? allAnnouncements : allAnnouncements.take(4))
                                      .map((ann) => Container(
                                      margin: const EdgeInsets.symmetric(vertical: 3.0), // more space between announcements
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(18,18,18,1),
                                        borderRadius: BorderRadius.circular(12.0),
                                      ),
                                    child: Text(
                                      ann,
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ))
                                      .toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    GradientTitle(text:"Materials",size:30),
                    const SizedBox(height: 8),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [Color.fromRGBO(104, 24, 131, 1.0), Color.fromRGBO(
                            113, 0, 0, 1.0), Color.fromRGBO(
                            0, 49, 124, 1.0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                      child: Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.horizontal(left:Radius.circular(20),right: Radius.circular(20)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ]),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, idx) {
                    final item =downloadableMaterials[idx];
                        return DownloadTile(
                            title: item['title']!,
                        href: item['href']!,
                        onDownload: () async {
                          await downloadFile(context,item['href']!, item['title']!);
                        });
                  },
                  childCount: downloadableMaterials.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
