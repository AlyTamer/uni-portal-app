import 'package:ntlm/ntlm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';
import 'dart:io';

class CmsService {
  Future<NTLMClient> _createClient() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('savedUsername') ?? '';
    final password = prefs.getString('savedPassword') ?? '';
    print("DEBUG: Using username: $username");
    print("DEBUG: Using password: ${password}");

    return NTLMClient(
      domain: 'guc.edu.eg',
      username: username,
      password: password,
    );
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final client = await _createClient();
    final response = await client.get(
      Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
    );

    print("HTTP status: ${response.statusCode}");

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch courses');
    }

    final document = parser.parse(response.body);
    final seasonElements = document.querySelectorAll('.menu-header-title');
    print("DEBUG: Found ${seasonElements.length} season elements");

    List<Map<String, dynamic>> results = [];

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
            final rows = cardBody.querySelectorAll('table tr');

            for (var row in rows.skip(1)) {
              final cells = row.querySelectorAll('td');
              if (cells.length >= 5) {
                final courseName = _cleanCourseName(cells[1].text.trim());
                final idValue = cells[3].text.trim(); // course id
                final sidValue = cells[4].text.trim(); // season id
                final courseUrl = "https://cms.guc.edu.eg/apps/student/CourseViewStn.aspx?id=$idValue&sid=$sidValue";

                results.add({
                  'season': seasonTitle,
                  'name': courseName,
                  'url': courseUrl,
                });
              }
            }

          }
        }
      }
    }

    return results;
  }



  Future<List<String>> fetchAnnouncements(String courseUrl) async {
    final client = await _createClient();
    final response = await client.get(Uri.parse(courseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch course page');
    }

    final document = parser.parse(response.body);
    final annContainer = document.querySelector('#ContentPlaceHolderright_ContentPlaceHoldercontent_desc');
    if (annContainer != null) {
      // Split by lines, remove empty, trim
      return annContainer.text
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
    }
    return [];
  }


  String _cleanCourseName(String raw) {
    raw = raw.replaceAll(RegExp(r'\(\d+\)$'), '').trim();
    raw = raw.replaceAllMapped(
      RegExp(r'\(\|([^)]+)\|\)'),
          (match) => '|${match.group(1)}|',
    );
    raw = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return raw;
  }
}
