import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:ntlm/ntlm.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/connectivity_service.dart';

class CmsService {
  static const _cacheKey = "cache_all_courses";
  static const _cacheTimeKey = "cache_all_courses_time";
  static const Duration _maxAge = Duration(hours: 3);
  final _coursesRefreshedCtr = StreamController<void>.broadcast();
  Stream<void> get coursesRefreshed => _coursesRefreshedCtr.stream;
  Future<List<Map<String, dynamic>>> getCachedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached == null) return const [];
    return _parseCourses(cached);
  }
  Future<String?> getCachedCourseHtml(String courseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("cache_course_$courseUrl");
  }

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
    } on Exception catch (_) {
      throw Exception('Failed to create NTLM client');
    }
  }

  Future<List<Map<String, dynamic>>> fetchCourses() async {
    final prefs = await SharedPreferences.getInstance();

    final bool online = ConnectivityService.instance.isOnline;

    if (online) {
      try {
        final client = await _createClient();
        final response = await client.get(
          Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
        );
        if (response.statusCode != 200) throw Exception('Failed');

        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

        return _parseCourses(response.body);
      } catch (_) {
      }
    }

    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      return _parseCourses(cached);
    }

    throw StateError('No cached courses available.');
  }
  Future<List<Map<String, dynamic>>> fetchCoursesSWR() async {
    final prefs = await SharedPreferences.getInstance();

    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      Future.microtask(() => _refreshCoursesInBackground(notify: true));
      return _parseCourses(cached);
    }

    try {
      final client = await _createClient();
      final response = await client.get(
        Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
      );
      if (response.statusCode != 200) throw Exception('Failed');

      await prefs.setString(_cacheKey, response.body);
      await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      _coursesRefreshedCtr.add(null);

      return _parseCourses(response.body);
    } catch (_) {
      throw StateError('No cached courses available.');
    }
  }

  Future<void> refreshCoursesIfStale({Duration? maxAge}) async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_cacheTimeKey) ?? 0;
    final ageMs = DateTime.now().millisecondsSinceEpoch - ts;
    final limit = (maxAge ?? _maxAge).inMilliseconds;

    if (ageMs >= limit) {
      await _refreshCoursesInBackground();
    }
  }

  Future<void> _refreshCoursesInBackground({bool notify = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final client = await _createClient();
      final response = await client.get(
        Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
      );
      if (response.statusCode == 200) {
        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
        if (notify) _coursesRefreshedCtr.add(null);
      }
    } catch (_) {/* ignore */}
  }

  final _coursePageRefreshedCtr = StreamController<String>.broadcast();
  Stream<String> get coursePageRefreshed => _coursePageRefreshedCtr.stream;

  Future<String> fetchCourseHtmlSWR(String courseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "cache_course_$courseUrl";
    final cacheTimeKey = "cache_course_${courseUrl}_time";

    final cached = prefs.getString(cacheKey);
    if (cached != null) {
      Future.microtask(() async {
        try {
          final client = await _createClient();
          final resp = await client.get(Uri.parse(courseUrl));
          if (resp.statusCode == 200) {
            await prefs.setString(cacheKey, resp.body);
            await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
            _coursePageRefreshedCtr.add(courseUrl);
          }
        } catch (_) {}
      });
      return cached;
    }

    final client = await _createClient();
    final resp = await client.get(Uri.parse(courseUrl));
    if (resp.statusCode != 200) {
      throw Exception('Failed to fetch course HTML');
    }
    await prefs.setString(cacheKey, resp.body);
    await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    _coursePageRefreshedCtr.add(courseUrl);
    return resp.body;
  }

  List<Map<String, dynamic>> _parseCourses(String html) {
    final document = parser.parse(html);
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
                final idValue = cells[3].text.trim();
                final sidValue = cells[4].text.trim();
                final courseUrl =
                    "https://cms.guc.edu.eg/apps/student/CourseViewStn.aspx?id=$idValue&sid=$sidValue";

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

String _sanitizeFileName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[\\/:*?"<>|\r\n]+'), ' ').trim();
  return cleaned.isEmpty ? 'download' : cleaned;
}

String _extFromContentType(String? ct) {
  switch ((ct ?? '').toLowerCase().split(';').first.trim()) {
    case 'application/pdf':
      return '.pdf';
    case 'application/zip':
      return '.zip';
    case 'application/x-zip-compressed':
      return '.zip';
    case 'application/rar':
    case 'application/x-rar-compressed':
      return '.rar';
    case 'application/msword':
      return '.doc';
    case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
      return '.docx';
    case 'application/vnd.ms-excel':
      return '.xls';
    case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      return '.xlsx';
    case 'application/vnd.ms-powerpoint':
      return '.ppt';
    case 'application/vnd.openxmlformats-officedocument.presentationml.presentation':
      return '.pptx';
    case 'image/png':
      return '.png';
    case 'image/jpeg':
      return '.jpg';
    case 'image/gif':
      return '.gif';
    case 'text/plain':
      return '.txt';
    default:
      return '';
  }
}

String _extFromPath(String url) {
  final last = Uri.tryParse(url)?.pathSegments.last ?? '';
  final dot = last.lastIndexOf('.');
  if (dot > 0 && dot < last.length - 1) {
    final ext = last.substring(dot);
    if (ext.length <= 6) return ext;
  }
  return '';
}

String _filenameFromContentDisposition(String? cd) {
  if (cd == null) return '';


  final fnStar = RegExp(
    "filename\\*\\s*=\\s*[^'\"]*'[^'\"]*'([^;]+)",
    caseSensitive: false,
  ).firstMatch(cd);
  if (fnStar != null) return Uri.decodeFull(fnStar.group(1)!.trim());


  final fnQuoted = RegExp(
    r'filename\s*=\s*"([^"]+)"',
    caseSensitive: false,
  ).firstMatch(cd);
  if (fnQuoted != null) return fnQuoted.group(1)!.trim();


  final fnBare = RegExp(
    r'filename\s*=\s*([^;]+)',
    caseSensitive: false,
  ).firstMatch(cd);
  if (fnBare != null) return fnBare.group(1)!.trim().replaceAll('"', '');

  return '';
}

String _ensureExtension({
  required String displayName,
  required String url,
  required Map<String, String> headers,
}) {

  final fromCD = _filenameFromContentDisposition(
    headers['content-disposition'],
  );
  String base = _sanitizeFileName(fromCD.isNotEmpty ? fromCD : displayName);

  String currentExt = '';
  final dot = base.lastIndexOf('.');
  if (dot > 0 && dot < base.length - 1) {
    currentExt = base.substring(dot).toLowerCase();
  }

  if (currentExt.isEmpty) currentExt = _extFromPath(url);

  if (currentExt.isEmpty) {
    currentExt = _extFromContentType(headers['content-type']);
  }

  if (currentExt.isEmpty) currentExt = '.bin';

  if (!base.toLowerCase().endsWith(currentExt)) {
    base = '$base$currentExt';
  }
  return base;
}

String _downloadKeyFor(String href) {

  return 'cms_file_${base64Url.encode(utf8.encode(href))}';
}

Future<void> _rememberDownloadedPath(String href, String absolutePath) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_downloadKeyFor(href), absolutePath);
}

Future<String?> getRememberedDownloadedPath(String href) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_downloadKeyFor(href));
}

Future<void> downloadFile(
  BuildContext context,
  String relativePath,
  String filename,
) async {
  try {

    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted == false) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Storage permission denied")),
          );
          return;
        }
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('savedUsername')?.toLowerCase() ?? '';
    final password = prefs.getString('savedPassword') ?? '';

    final client = NTLMClient(
      domain: 'guc.edu.eg',
      username: username,
      password: password,
    );

    final url = "https://cms.guc.edu.eg$relativePath";
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {

      final saveName = _ensureExtension(
        displayName: filename,
        url: url,
        headers: response.headers,
      );

      Directory downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory("/storage/emulated/0/Download");
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      final filePath = "${downloadDir.path}/$saveName";
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);
      await _rememberDownloadedPath(relativePath, filePath);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Downloaded: $saveName",
            style: Theme.of(context).textTheme.titleSmall,
          ),
          backgroundColor: Colors.deepPurple,
        ),
      );

      await OpenFile.open(filePath);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed: ${response.statusCode}")));
    }
  } catch (e) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Error: $e")));
  }
}
