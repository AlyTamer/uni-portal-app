import 'dart:io';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:open_file/open_file.dart';
import 'package:uni_portal_app/functions/cms/cms_web_service.dart';
import 'package:uni_portal_app/widgets/content_download_tile_widget.dart';
import 'package:uni_portal_app/widgets/custom_drawer_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';

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
bool _looksLikeVideo(String title, String href) {
  final t = title.toLowerCase();
  final h = href.toLowerCase();
  const videoKeywords = ['video', 'vod', 'vods', 'lecture recording', 'recording'];
  const videoExts = ['.mp4', '.m4v', '.mov', '.webm', '.mkv', '.avi'];
  final last = Uri.tryParse(h)?.pathSegments.last.toLowerCase() ?? '';
  final hasKeyword = videoKeywords.any((k) => t.contains(k) || last.contains(k));
  final hasExt = videoExts.any((ext) => t.endsWith(ext) || last.endsWith(ext));
  final pathSignals = h.contains('/vod') || h.contains('video');
  return hasKeyword || hasExt || pathSignals;
}
Future<String?> _findExistingLocalPath(String href) async {
  final remembered = await getRememberedDownloadedPath(href);
  if (remembered != null && remembered.isNotEmpty) {
    final f = File(remembered);
    if (await f.exists()) return remembered;
  }
  return null;
}

Future<void> _loadData() async {
  final cms = CmsService();
  final html = await cms.fetchCourseHtml(widget.courseUrl);
  final doc = parse(html);

  final annContainer = doc.querySelector('#ContentPlaceHolderright_ContentPlaceHoldercontent_desc');
  final anns = annContainer != null
      ? annContainer.text
      .split('\n')
      .map<String>((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList()
      : <String>[];
  final contentBlocks = doc.querySelectorAll('div[id^="content"]');
  final List<Map<String, String>> materials = [];

  for (final block in contentBlocks) {
    final strongElement = block.querySelector('strong');
    if (strongElement == null) continue;

    String filename = strongElement.text.trim();
    filename = filename.replaceFirst(RegExp(r'^\(\|.*?\|\)\s*'), '').trim();
    filename = filename.replaceFirst(RegExp(r'^\d+\s*-\s*'), '').trim();

    final linkElement = block.nextElementSibling
        ?.nextElementSibling
        ?.querySelector('a#download');

    final href = linkElement?.attributes['href']?.trim() ?? '';
    if (href.isEmpty) continue;

    if (_looksLikeVideo(filename, href)) continue;


    materials.add({
      'title': filename,
      'href': href,
    });
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
    return WillPopScope(
      onWillPop: () async {
        if(showAll){
          setState(() {
            showAll=false;
          });
          return false;
        }
        return true;

      },
      child: SafeArea(
        child: Center(
          child: isLoading? CircularProgressIndicator():
          Scaffold(
            drawer: CustomDrawerWidget(),
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
                                        margin: const EdgeInsets.symmetric(vertical: 3.0),
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
                      final item = downloadableMaterials[idx];
                      final title = item['title']!;
                      final href  = item['href']!;

                      return FutureBuilder<String?>(
                        future: _findExistingLocalPath(href),
                        builder: (context, snap) {
                          final existingPath = snap.data;
                          final isDownloaded = existingPath != null;


                          return DownloadTile(
                            title: title,
                            href: href,
                            isDownloaded: isDownloaded,

                            onDownload: () async {
                              if (isDownloaded) {

                                await OpenFile.open(existingPath);
                              } else {
                                await downloadFile(context, href, title);
                                setState(() {});
                              }
                            },
                          );
                        },
                      );
                    },
                    childCount: downloadableMaterials.length,
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
