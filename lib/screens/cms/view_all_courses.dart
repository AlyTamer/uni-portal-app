import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_portal_app/functions/cms/cms_web_service.dart';
import 'package:uni_portal_app/widgets/offline_banner_widget.dart';

import 'acitve_course_screen.dart';

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  final _cms = CmsService();
  StreamSubscription<void>? _coursesSub;
  List<Map<String, dynamic>> allCourses = [];
  String? selectedSeason;
  List<Map<String, String>> selectedCourses = [];
  List<String> allSeasons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    // 1) Paint immediately from cache if present (and start background refresh).
    _loadSeasonsSWR();

    // 2) Repaint when fresh HTML lands.

    _coursesSub = _cms.coursesRefreshed.listen((_) async {
      final latest = await _cms.getCachedCourses();
      if (!mounted) return;
      setState(() {
        allCourses = latest;
        allSeasons = allCourses.map((c) => c['season'] as String).toSet().toList();

        if (selectedSeason != null) {
          // Rebuild the course list for the currently selected season (if it still exists)
          if (allSeasons.contains(selectedSeason)) {
            selectedCourses = allCourses
                .where((c) => c['season'] == selectedSeason)
                .map<Map<String, String>>((c) => {
              'name': c['name'] as String,
              'url': c['url'] as String,
            })
                .toList();
          } else {
            selectedSeason = null;
            selectedCourses = [];
          }
        }
      });
    });
  }
  @override
  void dispose() {
    _coursesSub?.cancel();
    super.dispose();
  }

  Future<void> _loadSeasonsSWR() async {
    setState(() => isLoading = true);
    try {
      final data = await _cms.fetchCoursesSWR(); // cache now, refresh in bg
      if (!mounted) return;
      setState(() {
        allCourses = data;
        allSeasons = allCourses.map((c) => c['season'] as String).toSet().toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }


  void _onSeasonSelected(String season) {
    setState(() {
      selectedSeason = season;
      selectedCourses = allCourses
          .where((course) => course['season'] == season)
          .map<Map<String, String>>((c) => {
        'name': c['name'] as String,
        'url': c['url'] as String
      })
          .toList();
    });
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: OfflineBanner(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: const Color.fromRGBO(1, 1, 1, 1),
            title: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.purple, Colors.pink, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                'CMS',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      Colors.purpleAccent,
                      Colors.pink,
                      Colors.lightBlue,
                    ],
                    begin: Alignment.topRight,
                    end: Alignment.centerLeft,
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(65, 65, 65, 1),
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    height: 70,
                    width: double.infinity,
                    child: Center(
                      child: DropdownButton<String>(
                        value: selectedSeason,
                        hint: const Text('Select A Season'),
                        dropdownColor: Colors.black,
                        items: allSeasons
                            .map((season) => DropdownMenuItem(
                          value: season,
                          child: Text(season),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _onSeasonSelected(value);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: selectedCourses.length,
                    itemBuilder: (context, idx) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: ListTile(
                          title: Text(selectedCourses[idx]['name']!,style: Theme.of(context).textTheme.titleMedium,),
                          leading: const Icon(Icons.arrow_right, color: Colors.deepPurple,size: 60,),
                          tileColor: Color.fromRGBO(10, 10, 10, 1),
                          onTap: () {

                            Navigator.push(context,MaterialPageRoute(
                              builder:(context)=>ActiveCourse(courseName: selectedCourses[idx]['name']!, courseUrl: selectedCourses[idx]['url']!)
                            ));
                          },
                        ),
                      );
                    },
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
