import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntlm/ntlm.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;


class ScheduleSlot {
  final int slot;
  final String title;
  final String course;
  final String room;
  final String start;
  final String end;
  final bool isFree;

  const ScheduleSlot({
    required this.slot,
    required this.title,
    required this.course,
    required this.room,
    required this.start,
    required this.end,
    required this.isFree,
  });

  factory ScheduleSlot.free(int slot) => ScheduleSlot(
    slot: slot, title: 'Free', course: '', room: '', start: '', end: '', isFree: true,
  );
}

class SearchItem {
  final String id;
  final String value;
  const SearchItem({required this.id, required this.value});

  @override
  String toString() => '$value ($id)';
}

class SearchLists {
  final List<SearchItem> courses;
  final List<SearchItem> staff;
  const SearchLists({required this.courses, required this.staff});
}


class ScheduleService {


  Future<Map<String, List<ScheduleSlot>>> fetchSchedule() async {
    final html = await _fetchGroupScheduleHtml();
    return _parseGroupSchedule(html);
  }


  Future<SearchLists> fetchSearchLists() async {
    final client = await _createClient();
    final uri = Uri.parse(
      'https://apps.guc.edu.eg/student_ext/Scheduling/SearchAcademicScheduled_001.aspx',
    );

    final resp = await client.get(uri);
    if (resp.statusCode != 200) {
      throw HttpException('Academic Schedule page returned ${resp.statusCode}');
    }

    final html = resp.body;

    final coursesRaw = _extractJsArray(html: html, variableName: 'courses');
    final tasRaw     = _extractJsArray(html: html, variableName: 'tas');

    if (coursesRaw == null || tasRaw == null) {
      throw StateError('Could not locate courses/tas arrays in response HTML');
    }

    final courses = _parseJsObjectsArray(coursesRaw);
    final staff   = _parseJsObjectsArray(tasRaw);

    return SearchLists(courses: courses, staff: staff);
  }

  List<SearchItem> filterItems(List<SearchItem> items, String query) {
    final q = query.trim();
    if (q.isEmpty) return items;


    try {
      final re = RegExp(q, caseSensitive: false);
      return items.where((i) => re.hasMatch(i.value)).toList();
    } catch (_) {

      final lq = q.toLowerCase();
      return items.where((i) => i.value.toLowerCase().contains(lq)).toList();
    }
  }

  void logSelection(SearchItem item, {String label = 'Selected'}) {
    debugPrint('$label: ${item.value}');
  }


  Future<String> _fetchGroupScheduleHtml() async {
    final client = await _createClient();
    final uri = Uri.parse('https://apps.guc.edu.eg/student_ext/Scheduling/GroupSchedule.aspx');
    final res = await client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to fetch schedule page (${res.statusCode})');
    }
    return res.body;
  }

  Future<NTLMClient> _createClient() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('savedUsername')?.toLowerCase() ?? '';
    final password = prefs.getString('savedPassword') ?? '';
    return NTLMClient(domain: 'guc.edu.eg', username: username, password: password);
  }

  static const _days = ['Sat','Sun','Mon','Tue','Wed','Thu'];
  static const _slotTimes = <List<String>>[
    ['8:15 AM','9:45 AM'],
    ['10:00 AM','11:30 AM'],
    ['11:45 AM','1:15 PM'],
    ['1:45 PM','3:15 PM'],
    ['3:45 PM','5:15 PM'],
  ];

  Map<String, List<ScheduleSlot>> _parseGroupSchedule(String html) {
    final doc = parser.parse(html);

    final table = doc.querySelector('#ContentPlaceHolderright_ContentPlaceHoldercontent_scdTbl');
    if (table == null) {
      return {for (final d in _days) d: List.generate(5, (i) => ScheduleSlot.free(i+1))};
    }

    final out = <String, List<ScheduleSlot>>{};

    for (int d = 0; d < _days.length; d++) {
      final dayIdx = d + 1; // 1..6
      final dayKey = _days[d];

      final altRow = doc.querySelector(
          '#ContentPlaceHolderright_ContentPlaceHoldercontent_XaltR$dayIdx');
      final allFree = altRow?.text.toLowerCase().contains('free') == true;

      final slots = <ScheduleSlot>[];

      for (int s = 0; s < 5; s++) {
        final slot = s + 1;

        if (allFree) {
          slots.add(ScheduleSlot.free(slot));
          continue;
        }

        final span = doc.querySelector(
            '#ContentPlaceHolderright_ContentPlaceHoldercontent_XlblR${dayIdx}C$slot');
        String text = _clean(span?.text ?? '');

        if (text.isEmpty) {
          final dayRow = doc.querySelector(
              '#ContentPlaceHolderright_ContentPlaceHoldercontent_Xrw$dayIdx');
          dom.Element? cell;
          if (dayRow != null) {
            final tds = dayRow.querySelectorAll('td');
            if (slot - 1 >= 0 && slot - 1 < tds.length) {
              cell = tds[slot - 1];
            }
          }
          text = _clean(cell?.text ?? '');
        }

        if (text.isEmpty || text.toLowerCase() == 'free') {
          slots.add(ScheduleSlot.free(slot));
        } else {
          final room = _extractRoom(text);
          final start = _slotTimes[s][0];
          final end = _slotTimes[s][1];
          slots.add(ScheduleSlot(
            slot: slot,
            title: text,
            course: text,
            room: room,
            start: start,
            end: end,
            isFree: false,
          ));
        }
      }

      out[dayKey] = slots;
    }

    return out;
  }

  String _clean(String s) =>
      s.replaceAll('\u00A0', ' ').trim().replaceAll(RegExp(r'\s+'), ' ');

  String _extractRoom(String s) {

    final m = RegExp(r'\b[A-Z]\d\.\d{3}\b').firstMatch(s);
    return m?.group(0) ?? '';
  }


  String? _extractJsArray({required String html, required String variableName}) {

    final reg = RegExp(
      r'(?m)'
      r'(^|[\s;])' +
          RegExp.escape(variableName) +
          r'\s*=\s*\[(.*?)\];',
      dotAll: true,
    );
    final m = reg.firstMatch(html);
    if (m == null) return null;
    return m.group(2);
  }

  List<SearchItem> _parseJsObjectsArray(String arrayContent) {
    final src = arrayContent.replaceAll('\u00A0', ' ');

    final objRe = RegExp(
      r"\{\s*'id'\s*:\s*'([^']*)'\s*,\s*'value'\s*:\s*'([^']*)'\s*\}",
      dotAll: true,
    );

    final out = <SearchItem>[];
    for (final m in objRe.allMatches(src)) {
      final id = m.group(1)!.trim();
      final value = m.group(2)!.trim();
      out.add(SearchItem(id: id, value: value));
    }
    return out;
  }
}
