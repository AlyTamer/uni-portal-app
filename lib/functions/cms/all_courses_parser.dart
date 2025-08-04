import 'package:ntlm/ntlm.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'package:shared_preferences/shared_preferences.dart';


Future<List<List<dynamic>>> fetchCourses() async {
  print("fetchCourses() started");
  final prefs = await SharedPreferences.getInstance();
  if(prefs.getString('savedUsername') == null ||
     prefs.getString('savedPassword') == null) {
    print("No saved credentials found, cannot fetch courses.");
    throw Exception('No saved credentials found');
  }

  late NTLMClient client;
  try {
     client = NTLMClient(
      domain: 'guc.edu.eg',
       username: prefs.getString('savedUsername') ?? '',
       password: prefs.getString('savedPassword') ?? '',
    );
  } on Exception catch (e) {
    print("Error creating NTLMClient: $e");
    throw Exception('Failed to create NTLM client: $e');
  }

  final response = await client.get(
    Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
  );

  print("HTTP status: ${response.statusCode}");

  if (response.statusCode != 200) {
    print("Login failed!");
    throw Exception('Login failed: ${response.statusCode}');
  }

  print("Login successful, parsing HTML...");

  final document = parser.parse(response.body);
  final seasonElements = document.querySelectorAll('.menu-header-title');

  List<List<dynamic>> seasonsWithCourses = [];

  for (var seasonEl in seasonElements) {
    final seasonText = seasonEl.text.trim();
    final titleMatch = RegExp(r'Title:\s*(.+)$').firstMatch(seasonText);

    if (titleMatch != null) {
      String seasonTitle = titleMatch.group(1)!.trim();

      Element? parent = seasonEl.parent;
      while (parent != null && !parent.classes.contains('card')) {
        parent = parent.parent;
      }

      if (parent != null) {
        final cardBody = parent.querySelector('.card-body');
        if (cardBody != null) {
          final courseNames = cardBody
              .querySelectorAll('table tr td:nth-child(2)')
              .map((td) => _cleanCourseName(td.text.trim()))
              .where((name) => name.isNotEmpty && name != 'Name')
              .toList();


          seasonsWithCourses.add([seasonTitle, courseNames]);
        }
      }
    }
  }

  print('Parsed seasons & courses: $seasonsWithCourses');
  return seasonsWithCourses;
}
String _cleanCourseName(String raw) {
  // Remove the trailing "(123)" number part
  raw = raw.replaceAll(RegExp(r'\(\d+\)$'), '').trim();

  // Convert "(|CODE|)" to "|CODE|"
  raw = raw.replaceAllMapped(
    RegExp(r'\(\|([^)]+)\|\)'),
        (match) => '|${match.group(1)}|',
  );

  // Normalize multiple spaces
  raw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();

  return raw;
}


