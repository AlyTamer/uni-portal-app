import 'package:flutter/material.dart';
import 'package:ntlm/ntlm.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class CmsService {
  Future<NTLMClient> _createClient() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('savedUsername')?.toLowerCase() ?? '';
    final password = prefs.getString('savedPassword') ?? '';


    try {

      return NTLMClient(
        domain: 'guc.edu.eg',
        username: username,
        password: password,
      );
    } on Exception catch (e) {

      throw Exception('Failed to create NTLM client');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final client = await _createClient();
    final response = await client.get(
      Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
    );



    if (response.statusCode != 200) {
      throw Exception('Failed to fetch courses');
    }

    final document = parser.parse(response.body);
    final seasonElements = document.querySelectorAll('.menu-header-title');


    List<Map<String, dynamic>> results = [];

    for (var seasonEl in seasonElements) {
      final seasonText = seasonEl.text.trim();
      final titleMatch = RegExp(r'Title:\s*(.+)$').firstMatch(seasonText);

      if (titleMatch != null) {
        String seasonTitle = titleMatch.group(1)!.trim();

        dom.Element? parent = seasonEl.parent;
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
  Future<String> fetchCourseHtml(String courseUrl) async {
    final client = await _createClient();
    final response = await client.get(Uri.parse(courseUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch course HTML');
    }
    return response.body;
  }

}
Future<void> downloadFile(BuildContext context, String relativePath, String filename) async {
  try {
    // Request permission
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted == false) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Storage permission denied")),
          );
          return;
        }
      }
    }

    // Load credentials
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('savedUsername')?.toLowerCase() ?? '';
    final password = prefs.getString('savedPassword') ?? '';

    // Create NTLM client
    final client = NTLMClient(
      domain: 'guc.edu.eg',
      username: username,
      password: password,
    );

    // Build full URL
    final url = "https://cms.guc.edu.eg$relativePath";


    // Fetch file
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Downloads folder path
      Directory downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory("/storage/emulated/0/Download");
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      // Save file
      final filePath = "${downloadDir.path}/$filename";
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);


      // Notify user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Downloaded: $filename",
              style: Theme.of(context).textTheme.titleSmall,
        ),
        backgroundColor: Colors.deepPurple,),
      );

      // Open the file
      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.statusCode}")),
      );
    }
  } catch (e) {

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}


