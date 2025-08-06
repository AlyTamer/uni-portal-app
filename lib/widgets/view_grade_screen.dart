import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/grade_widget_tile.dart';

class ViewGradeScreen extends StatefulWidget {
  final String? courseName;
  const ViewGradeScreen({super.key, required this.courseName});

  @override
  State<ViewGradeScreen> createState() => _ViewGradeScreenState();
}

class _ViewGradeScreenState extends State<ViewGradeScreen> {
  List<Map<String, dynamic>> grades = [
    {"name": "Quiz 1", "score": "7/10", "subtext": "N/A"},
    {"name": "Quiz 2", "score": "8/10", "subtext": "N/A"},
    {"name": "Midterm", "score": "15/20", "subtext": "N/A"},
    {"name": "Final Exam", "score": "18/20", "subtext": "N/A"},
    {"name": "Project", "score": "25/30", "subtext": "N/A"},
  ];
  @override
  Widget build(BuildContext context) {
    return  Expanded(
      child: ListView.builder(
        itemCount: grades.length,
        itemBuilder:(context,idx){
          return GradeTile(name: grades[idx]['name'],
              score: grades[idx]['score'],
              subtext: grades[idx]['subtext']);
        }
      ),
    );
  }
}
