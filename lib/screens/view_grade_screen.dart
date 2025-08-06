import 'package:flutter/material.dart';

import '../widgets/gradient_titles.dart';
import '../widgets/view_grade_screen.dart';

class GradeScreen extends StatefulWidget {
  const GradeScreen({super.key});

  @override
  State<GradeScreen> createState() => _GradeScreenState();
}

class _GradeScreenState extends State<GradeScreen> {
  List<String> courses=["Math","Science","History","English","Art"];
  String? selCourse;
  int selCourseIdx=0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:  Colors.transparent,
        leading:IconButton(
          icon: Icon(Icons.arrow_back, size:40,color:Colors.purple),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Center(child: GradientTitle(text: 'Grades',size:32)),
        titleSpacing:100,
      ),
      body:Padding(
        padding: const EdgeInsets.all(12.0),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selCourse,
                      hint: const Text('Select A Course'),
                      dropdownColor: Colors.black,
                      items: courses
                          .map((season) => DropdownMenuItem(
                        value: season,
                        child: Text(season),
                      ))
                          .toList(),
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          selCourse=value;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),
         const SizedBox(height:16),
            ViewGradeScreen(courseName: selCourse,),

          ],
        ),
      )
    );
  }
}
