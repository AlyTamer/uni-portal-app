import 'dart:convert';
import 'dart:io';

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

    // Always try online first IF online; otherwise skip straight to cache
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
        // fall through to cache
      }
    }

    // Offline OR online failed → serve cache if present (even if stale)
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      return _parseCourses(cached);
    }

    // No cache at all
    throw StateError('No cached courses available.');
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

  void _refreshCoursesOnReconnectListener() {
    // Call this ONCE when your app starts (e.g., in HomeScreen initState)
    ConnectivityService.instance.onlineStream.listen((online) {
      if (online) {
        refreshCoursesIfStale(); // fire-and-forget
      }
    });
  }

  Future<void> _refreshCoursesInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final client = await _createClient();
      final response = await client.get(
        Uri.parse('https://cms.guc.edu.eg/apps/student/ViewAllCourseStn'),
      );
      if (response.statusCode == 200) {
        await prefs.setString(_cacheKey, response.body);
        await prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
      }
    } catch (_) {/* ignore */}
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
                final idValue = cells[3].text.trim(); // course id
                final sidValue = cells[4].text.trim(); // season id
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

  List<String> _parseAnnouncements(String html) {
    final document = parser.parse(html);
    final annContainer = document.querySelector(
      '#ContentPlaceHolderright_ContentPlaceHoldercontent_desc',
    );
    return annContainer == null
        ? []
        : annContainer.text
              .split('\n')
              .map((line) => line.trim())
              .where((line) => line.isNotEmpty)
              .toList();
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

  Future<List<String>> fetchAnnouncements(String courseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "cache_announcements_$courseUrl";
    final cacheTimeKey = "cache_announcements_${courseUrl}_time";

    try {
      final client = await _createClient();
      final response = await client.get(Uri.parse(courseUrl));

      if (response.statusCode != 200) throw Exception('Failed');

      // Save HTML + timestamp
      await prefs.setString(cacheKey, response.body);
      await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

      return _parseAnnouncements(response.body);
    } catch (_) {
      final cached = prefs.getString(cacheKey);
      final ts = prefs.getInt(cacheTimeKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;

      if (cached != null && age < const Duration(hours: 6).inMilliseconds) {
        return _parseAnnouncements(cached);
      }

      rethrow;
    }
  }

  Future<String> fetchCourseHtml(String courseUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = "cache_course_$courseUrl";
    final cacheTimeKey = "cache_course_${courseUrl}_time";

    try {
      final client = await _createClient();
      final response = await client.get(Uri.parse(courseUrl));

      if (response.statusCode == 200) {
        // Save HTML + timestamp
        await prefs.setString(cacheKey, response.body);
        await prefs.setInt(cacheTimeKey, DateTime.now().millisecondsSinceEpoch);

        return response.body;
      } else {
        throw Exception('Failed to fetch course HTML');
      }
    } catch (_) {
      final cached = prefs.getString(cacheKey);
      final ts = prefs.getInt(cacheTimeKey) ?? 0;
      final age = DateTime.now().millisecondsSinceEpoch - ts;

      if (cached != null && age < const Duration(hours: 6).inMilliseconds) {
        return cached;
      }

      rethrow;
    }
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
    if (ext.length <= 6) return ext; // basic sanity
  }
  return '';
}

String _filenameFromContentDisposition(String? cd) {
  if (cd == null) return '';

  // RFC 5987 / 6266: filename*=
  // Use a NON-RAW double-quoted string and escape \" and \\.
  final fnStar = RegExp(
    "filename\\*\\s*=\\s*[^'\"]*'[^'\"]*'([^;]+)",
    caseSensitive: false,
  ).firstMatch(cd);
  if (fnStar != null) return Uri.decodeFull(fnStar.group(1)!.trim());

  // filename="..."
  final fnQuoted = RegExp(
    r'filename\s*=\s*"([^"]+)"',
    caseSensitive: false,
  ).firstMatch(cd);
  if (fnQuoted != null) return fnQuoted.group(1)!.trim();

  // filename=...
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
  // 1) take filename from Content-Disposition if present
  final fromCD = _filenameFromContentDisposition(
    headers['content-disposition'],
  );
  String base = _sanitizeFileName(fromCD.isNotEmpty ? fromCD : displayName);

  // does base already contain an extension?
  String currentExt = '';
  final dot = base.lastIndexOf('.');
  if (dot > 0 && dot < base.length - 1) {
    currentExt = base.substring(dot).toLowerCase();
  }

  // 2) if no ext yet, try URL path
  if (currentExt.isEmpty) currentExt = _extFromPath(url);

  // 3) if still none, infer from Content-Type
  if (currentExt.isEmpty)
    currentExt = _extFromContentType(headers['content-type']);

  // 4) still nothing → .bin fallback
  if (currentExt.isEmpty) currentExt = '.bin';

  if (!base.toLowerCase().endsWith(currentExt)) {
    base = '$base$currentExt';
  }
  return base;
}

String _downloadKeyFor(String href) {
  // unique, filesystem-safe key for this content link
  return 'cms_file_' + base64Url.encode(utf8.encode(href));
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
    // Permissions (unchanged)
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
      // Build a safe, correct save name with extension
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
