import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ntlm/ntlm.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import 'dart:convert';


class SlotDetail {
  final String course;
  final String room;
  final String instructor;
  final String type;

  const SlotDetail({
    this.course = '',
    this.room = '',
    this.instructor = '',
    this.type = '',
  });
}


class ScheduleSlot {
  final int slot;
  final String title;
  final String course;
  final String room;
  final String start;
  final String end;
  final bool isFree;
  final List<SlotDetail> details; // NEW

  const ScheduleSlot({
    required this.slot,
    required this.title,
    required this.course,
    required this.room,
    required this.start,
    required this.end,
    required this.isFree,
    this.details = const [], // NEW
  });

  factory ScheduleSlot.free(int slot) => ScheduleSlot(
    slot: slot,
    title: 'Free',
    course: '',
    room: '',
    start: '',
    end: '',
    isFree: true,
    details: const [], // NEW
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
    final ntlm = await _createClient();
    final uri = Uri.parse('https://apps.guc.edu.eg/student_ext/Scheduling/SearchAcademicScheduled_001.aspx');

    // Mimic a desktop browser so the page returns the script with arrays.
    const headers = {
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
    };

    final resp = await ntlm.get(uri, headers: headers);
    final html = resp.body;

    if (kDebugMode) {
      final title = parser.parse(html).querySelector('title')?.text ?? '(no title)';
      final snippet = html.substring(0, html.length > 600 ? 600 : html.length);
      debugPrint('NTLM fetch -> status: ${resp.statusCode}, title: $title');
      debugPrint('HTML head snippet:\n$snippet');
    }

    if (resp.statusCode != 200 || !_pageHasArrays(html)) {
      throw StateError('Could not locate courses/tas arrays in response HTML');
    }

    final coursesRaw = _extractJsArray(html: html, variableName: 'courses')!;
    final tasRaw     = _extractJsArray(html: html, variableName: 'tas')!;

    final courses = _parseJsObjectsArray(coursesRaw);
    final staff   = _parseJsObjectsArray(tasRaw);
    final coursesTagged = courses.map((c) {
      final ty = _inferTypeForName(c.value);
      return SearchItem(id: c.id, value: ty.isNotEmpty ? '${c.value} ($ty)' : c.value);
    }).toList();

    return SearchLists(courses: coursesTagged, staff: staff);

  }


  String? _extractJsArray({required String html, required String variableName}) {
    final pair = RegExp(
      r'\bcourses\s*=\s*(\[[\s\S]*?\])\s*,\s*tas\s*=\s*(\[[\s\S]*?\])',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(html);
    if (pair != null) {
      return variableName.toLowerCase() == 'courses' ? pair.group(1) : pair.group(2);
    }

    final single = RegExp(
      r'\b(?:var|let|const)?\s*' +
          RegExp.escape(variableName) +
          r'\s*=\s*(\[[\s\S]*?\])(?=\s*(?:[;,]|</script>))',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(html);
    if (single != null) return single.group(1);

    final loose = RegExp(
      r'\b' + RegExp.escape(variableName) + r'\s*=\s*(\[[\s\S]*?\])',
      multiLine: true,
      caseSensitive: false,
    ).firstMatch(html);
    return loose?.group(1);
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
    final uri = Uri.parse(
        'https://apps.guc.edu.eg/student_ext/Scheduling/GroupSchedule.aspx');
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
    if (username.isEmpty || password.isEmpty) {
      throw StateError('Missing saved NTLM credentials');
    }
    return NTLMClient(domain: 'guc.edu.eg', username: username, password: password);
  }


  static const _days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
  static const _slotTimes = <List<String>>[
    ['8:15 AM', '9:45 AM'],
    ['10:00 AM', '11:30 AM'],
    ['11:45 AM', '1:15 PM'],
    ['1:45 PM', '3:15 PM'],
    ['3:45 PM', '5:15 PM'],
  ];

  Map<String, List<ScheduleSlot>> _parseGroupSchedule(String html) {
    final doc = parser.parse(html);

    final table = doc.querySelector(
        '#ContentPlaceHolderright_ContentPlaceHoldercontent_scdTbl');
    if (table == null) {
      return {
        for (final d in _days) d: List.generate(
            5, (i) => ScheduleSlot.free(i + 1))
      };
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
        print(text);

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
        print("$text\nsecond time");

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


  List<SearchItem> _parseJsObjectsArray(String arrayContent) {
    final src = arrayContent.replaceAll('\u00A0', ' ').trim();

    // Fast path: strict JSON
    try {
      if (src.contains('"id"') && src.contains('"value"')) {
        final List<dynamic> arr = jsonDecode(src);
        return arr
            .whereType<Map<String, dynamic>>()
            .map((m) =>
            SearchItem(
              id: (m['id'] ?? '').toString().trim(),
              value: (m['value'] ?? '').toString().trim(),
            ))
            .toList();
      }
    } catch (_) {
      // fall through to tolerant regex mode
    }

    // Tolerant path: single OR double quotes for keys/values.
    // Raw triple-quoted string avoids all escaping issues.
    final objRe = RegExp(
      r'''\{\s*['"]id['"]\s*:\s*['"]([^'"]*)['"]\s*,\s*['"]value['"]\s*:\s*['"]([^'"]*)['"]\s*\}''',
      dotAll: true,
      multiLine: true,
    );

    final out = <SearchItem>[];
    for (final m in objRe.allMatches(src)) {
      out.add(SearchItem(
        id: m.group(1)!.trim(),
        value: m.group(2)!.trim(),
      ));
    }
    return out;
  }
  bool _pageHasArrays(String html) {
    final c = _extractJsArray(html: html, variableName: 'courses');
    final t = _extractJsArray(html: html, variableName: 'tas');
    return c != null && t != null;
  }

// --- Add to ScheduleService ---

  Future<Map<String, List<ScheduleSlot>>> fetchAcademicSchedule({
    List<String> courseIds = const [],
    List<String> staffIds  = const [],
  }) async {
    final client = await _createClient();
    final uri = Uri.parse(
      'https://apps.guc.edu.eg/student_ext/Scheduling/SearchAcademicScheduled_001.aspx',
    );

    const headers = {
      'User-Agent':
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
          '(KHTML, like Gecko) Chrome/124.0 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.9',
      'Connection': 'keep-alive',
    };

    // 1) GET page to capture tokens
    final getResp = await client.get(uri, headers: headers);
    if (getResp.statusCode != 200) {
      throw HttpException('GET Academic Schedule returned ${getResp.statusCode}');
    }
    final getDoc = parser.parse(getResp.body);
    final viewState  = getDoc.querySelector('#__VIEWSTATE')?.attributes['value'] ?? '';
    final viewGen    = getDoc.querySelector('#__VIEWSTATEGENERATOR')?.attributes['value'] ?? '';
    final eventValid = getDoc.querySelector('#__EVENTVALIDATION')?.attributes['value'] ?? '';
    if (viewState.isEmpty || eventValid.isEmpty) {
      throw StateError('Missing form tokens (__VIEWSTATE / __EVENTVALIDATION)');
    }

    // 2) POST "Show Schedule" with selections
    final body = _buildFormBody(
      singles: {
        '__EVENTTARGET': '',
        '__EVENTARGUMENT': '',
        '__VIEWSTATE': viewState,
        '__VIEWSTATEGENERATOR': viewGen,
        '__EVENTVALIDATION': eventValid,

        // This is the submit name of the "Show Schedule" button on that page
        r'ctl00$ctl00$ContentPlaceHolderright$ContentPlaceHoldercontent$B_ShowSchedule': 'Show Schedule',      },
      courseIds: courseIds,
      staffIds: staffIds,
    );

    final postResp = await client.post(
      uri,
      headers: {
        ...headers,
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
    if (postResp.statusCode != 200) {
      throw HttpException('POST Academic Schedule returned ${postResp.statusCode}');
    }

    return _parseAcademicSchedule(postResp.body);
  }

// Build x-www-form-urlencoded with repeated fields course[] / ta[]
  String _buildFormBody({
    required Map<String, String> singles,
    required List<String> courseIds,
    required List<String> staffIds,
  }) {
    final buf = StringBuffer();
    void add(String k, String v) {
      if (buf.isNotEmpty) buf.write('&');
      buf.write(Uri.encodeQueryComponent(k));
      buf.write('=');
      buf.write(Uri.encodeQueryComponent(v));
    }

    singles.forEach(add);
    for (final id in courseIds) add('course[]', id);
    for (final id in staffIds)  add('ta[]', id);

    return buf.toString();
  }

// Parse the schedule table (8 slots max per day). Leaves start/end empty.
  Map<String, List<ScheduleSlot>> _parseAcademicSchedule(String html) {
    // Local helpers (scoped to this method so you don’t have to add new members)
    String _typeFromText(String t) {
      final s = t.toLowerCase();

      // Full words
      if (RegExp(r'\b(tut|tutorial)\b').hasMatch(s)) return 'Tutorial';
      if (RegExp(r'\b(lec|lecture)\b').hasMatch(s)) return 'Lecture';
      if (RegExp(r'\b(lab|laboratory)\b').hasMatch(s)) return 'Lab';
      if (RegExp(r'\b(prac|practical)\b').hasMatch(s)) return 'Practical';

      // Short markers inside parentheses
      if (RegExp(r'\((?:t|tutorial)\)').hasMatch(s)) return 'Tutorial';
      if (RegExp(r'\((?:l|lecture)\)').hasMatch(s)) return 'Lecture';
      if (RegExp(r'\((?:lab|lb)\)').hasMatch(s)) return 'Lab';
      if (RegExp(r'\((?:prac|pr)\)').hasMatch(s)) return 'Practical';

      // Lone letters at word boundaries
      if (RegExp(r'(^|[\s\-_./])t($|[\s\-_./])').hasMatch(s)) return 'Tutorial';
      if (RegExp(r'(^|[\s\-_./])l($|[\s\-_./])').hasMatch(s)) return 'Lecture';
      if (RegExp(r'(^|[\s\-_./])(lb|lab)($|[\s\-_./])').hasMatch(s)) return 'Lab';
      if (RegExp(r'(^|[\s\-_./])(p|pr|prac)($|[\s\-_./])').hasMatch(s)) return 'Practical';

      return '';
    }


    bool _textAlreadyContainsType(String t) {
      final s = t.toLowerCase();
      return RegExp(r'\b(tut|tutorial|lec|lecture)\b').hasMatch(s) ||
          RegExp(r'\((?:t|tutorial|l|lecture)\)').hasMatch(s);
    }

    String _normalize(String s) => _clean(s); // reuse your existing _clean()

    final doc = parser.parse(html);
    final table = doc.querySelector(
        '#ContentPlaceHolderright_ContentPlaceHoldercontent_schedule');

    final days7 = const [
      'Saturday','Sunday','Monday','Tuesday','Wednesday','Thursday'];
    Map<String, List<ScheduleSlot>> emptyOut() => {
      for (final d in days7) d: List.generate(5, (i) => ScheduleSlot.free(i + 1)),
    };

    if (table == null) return emptyOut();

    final rows = table.querySelectorAll('tr');
    if (rows.length < 2) return emptyOut();

    final out = <String, List<ScheduleSlot>>{};

    // Row 0 header; rows 1.. are days
    for (int r = 1; r < rows.length; r++) {
      final cells = rows[r].querySelectorAll('th, td');
      if (cells.isEmpty) continue;

      final dayName = _normalize(cells.first.text);
      final slots = <ScheduleSlot>[];

      // Only first 5 slots are relevant
      final maxCols = (cells.length - 1).clamp(0, 5);
      for (int c = 1; c <= maxCols; c++) {
        final slotNum = c;
        final cell = cells[c];
        final slotDivs = cell.querySelectorAll('div.slot');

        if (slotDivs.isEmpty) {
          slots.add(ScheduleSlot.free(slotNum));
          continue;
        }

        final details = <SlotDetail>[];
        final seen = <String>{}; // for de-dup
        String preferredRoom = '';

        for (final div in slotDivs) {
          String group = '';
          String staff = '';
          String loc   = '';

          final dts = div.querySelectorAll('dt');
          final dds = div.querySelectorAll('dd');
          for (int i = 0; i < dts.length && i < dds.length; i++) {
            final k = _normalize(dts[i].text).toLowerCase();
            final v = _normalize(dds[i].text);
            if (k == 'group')    group = v;        // DO NOT split on "|" anymore
            else if (k == 'staff')   staff = v;
            else if (k == 'location') loc   = v;
          }

          if (loc.isNotEmpty) preferredRoom = loc;

          // If the whole block is empty, skip
          if (group.isEmpty && staff.isEmpty && loc.isEmpty) {
            continue;
          }

          // Determine type from text itself, then fallback to inference
          String ty = _typeFromText(group);
          if (ty.isEmpty) ty = _typeFromText(staff);
          if (ty.isEmpty) ty = _inferType(group, staff); // use your existing inference

          final key = '${group}||${staff}||${loc}||${ty}'.toLowerCase();
          if (seen.add(key)) {
            details.add(SlotDetail(course: group, room: loc, instructor: staff, type: ty));
          }
        }

        if (details.isEmpty) {
          slots.add(ScheduleSlot.free(slotNum));
          continue;
        }

        // Choose the first non-empty course as primary if possible
        final primary = details.firstWhere(
              (e) => e.course.isNotEmpty,
          orElse: () => details.first,
        );

        // Build title: if course text already contains (Lecture/Tutorial), keep it;
        // otherwise append inferred type if available.
        String titlePrimary = primary.course;
        if (!_textAlreadyContainsType(titlePrimary) && primary.type.isNotEmpty) {
          titlePrimary = '$titlePrimary (${primary.type})';
        }

        final roomPrimary =
        primary.room.isNotEmpty ? primary.room : preferredRoom;

        slots.add(ScheduleSlot(
          slot: slotNum,
          title: titlePrimary,        // e.g., "CLPH 1032 (Lecture)" or as-is from site
          course: primary.instructor, // second line on your tile
          room: roomPrimary,
          start: '',
          end: '',
          isFree: false,
          details: details,           // remaining items drive +N more & popup
        ));
      }

      // Ensure exactly 5
      while (slots.length < 5) {
        slots.add(ScheduleSlot.free(slots.length + 1));
      }
      out[dayName] = slots;
    }

    // Ensure all 7 days exist
    for (final d in days7) {
      out[d] ??= List.generate(5, (i) => ScheduleSlot.free(i + 1));
    }
    return out;
  }

  String _inferTypeForName(String name) {
    final s = name.toLowerCase();

    // Full words
    if (RegExp(r'\b(tut|tutorial)\b').hasMatch(s)) return 'Tutorial';
    if (RegExp(r'\b(lec|lecture)\b').hasMatch(s)) return 'Lecture';
    if (RegExp(r'\b(lab|laboratory)\b').hasMatch(s)) return 'Lab';
    if (RegExp(r'\b(prac|practical)\b').hasMatch(s)) return 'Practical';

    // Short markers and parentheses
    if (RegExp(r'\((?:t|tutorial)\)').hasMatch(s)) return 'Tutorial';
    if (RegExp(r'\((?:l|lecture)\)').hasMatch(s)) return 'Lecture';
    if (RegExp(r'\((?:lab|lb)\)').hasMatch(s)) return 'Lab';
    if (RegExp(r'\((?:prac|pr)\)').hasMatch(s)) return 'Practical';

    if (RegExp(r'(^|[\s\-_./])t($|[\s\-_./])').hasMatch(s)) return 'Tutorial';
    if (RegExp(r'(^|[\s\-_./])l($|[\s\-_./])').hasMatch(s)) return 'Lecture';
    if (RegExp(r'(^|[\s\-_./])(lb|lab)($|[\s\-_./])').hasMatch(s)) return 'Lab';
    if (RegExp(r'(^|[\s\-_./])(p|pr|prac)($|[\s\-_./])').hasMatch(s)) return 'Practical';

    return '';
  }

  String _inferType(String group, String staff) {
    final s = '${group} ${staff}'.toLowerCase();

    // Full words
    if (RegExp(r'\b(tut|tutorial)\b').hasMatch(s)) return 'Tutorial';
    if (RegExp(r'\b(lec|lecture)\b').hasMatch(s)) return 'Lecture';
    if (RegExp(r'\b(lab|laboratory)\b').hasMatch(s)) return 'Lab';
    if (RegExp(r'\b(prac|practical)\b').hasMatch(s)) return 'Practical';


    return '';
  }



}
