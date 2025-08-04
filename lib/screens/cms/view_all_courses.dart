import 'package:flutter/material.dart';
import 'package:uni_portal_app/functions/cms/all_courses_parser.dart';

import 'acitve_course_screen.dart'; // where fetchCourses() is

class ViewAllScreen extends StatefulWidget {
  const ViewAllScreen({super.key});

  @override
  State<ViewAllScreen> createState() => _ViewAllScreenState();
}

class _ViewAllScreenState extends State<ViewAllScreen> {
  List<List<dynamic>> seasonsWithCourses = [];
  String? selectedSeason;
  List<String> selectedCourses = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSeasons();
  }

  Future<void> _loadSeasons() async {
    try {
      final data = await fetchCourses();
      setState(() {
        seasonsWithCourses = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading courses: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSeasonSelected(String season) {
    setState(() {
      selectedSeason = season;
      selectedCourses = seasonsWithCourses
          .firstWhere((element) => element[0] == season)[1]
          .cast<String>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      items: seasonsWithCourses
                          .map((season) => DropdownMenuItem(
                        value: season[0] as String,
                        child: Text(season[0] as String),
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
              // Course list for selected season
              Expanded(
                child: ListView.builder(
                  itemCount: selectedCourses.length,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(selectedCourses[idx],style: Theme.of(context).textTheme.titleMedium,),
                        leading: const Icon(Icons.arrow_right, color: Colors.deepPurple,size: 50,),
                        tileColor: Color.fromRGBO(10, 10, 10, 1),
                        onTap: () {
                          print('Selected course: ${selectedCourses[idx]}');
                          Navigator.push(context,MaterialPageRoute(
                            builder:(context)=>ActiveCourse(courseName: selectedCourses[idx])
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
    );
  }
}
