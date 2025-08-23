import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/custom_drawer_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';

import '../../functions/schedule/schedule_service.dart';

import '../../widgets/day_tile_widget.dart';
import '../../widgets/schedule_item_widget.dart';
import '../about_me_screen.dart';
import '../login_screen.dart';
class OtherSchedules extends StatefulWidget {
  const OtherSchedules({super.key});

  @override
  State<OtherSchedules> createState() => _OtherSchedulesState();
}

class _OtherSchedulesState extends State<OtherSchedules> {

  static const List<String> dayTabs = ['Sat','Sun','Mon','Tue','Wed','Thu'];
  static const Map<String, String> _abbrToFull = {
    'Sat':'Saturday','Sun':'Sunday','Mon':'Monday','Tue':'Tuesday',
    'Wed':'Wednesday','Thu':'Thursday',
  };

  Map<String, List<ScheduleSlot>> _data = {
    for (final d in _abbrToFull.values) d: List.generate(5, (i) => ScheduleSlot.free(i + 1)),
  };

  bool _schedLoading = false;
  String? _schedError;
  int selIndex = 0;

  final _svc = ScheduleService();

  List<SearchItem> _coursesItems = [];
  List<SearchItem> _staffItems = [];

  List<String> allCourses = [];
  List<String> allStaff = [];

  late List<String> _visible;
  bool _showingCourses = true;

  String? selectedItem;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSearchLists();
  }

  Future<void> _fetchForSelection(String id) async {
    setState(() {
      _schedLoading = true;
      _schedError = null;
    });
    try {
      final map = await _svc.fetchAcademicSchedule(
        courseIds: _showingCourses ? [id] : const [],
        staffIds:  _showingCourses ? const [] : [id],
      );
      if (!mounted) return;
      setState(() => _data = map);
    } catch (e) {
      if (!mounted) return;
      setState(() => _schedError = e.toString());
    } finally {
      if (mounted) setState(() => _schedLoading = false);
    }
  }

  Future<void> _loadSearchLists() async {
    setState(() => isLoading = true);
    try {
      final lists = await _svc.fetchSearchLists();
      _coursesItems = lists.courses;
      _staffItems   = lists.staff;

      allCourses = _coursesItems.map((e) => e.value).toList();
      allStaff   = _staffItems.map((e) => e.value).toList();

      _visible = allCourses;
    } catch (e) {
      debugPrint('Search lists load error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void applyFilter(String query) {
    final items = _showingCourses ? _coursesItems : _staffItems;
    final filtered = _svc.filterItems(items, query);
    setState(() {
      _visible = filtered.map((e) => e.value).toList();
      selectedItem = null;
    });
  }

  void _onSelect(String value) {
    setState(() => selectedItem = value);
    final items = _showingCourses ? _coursesItems : _staffItems;
    final match = items.firstWhere(
          (i) => i.value == value,
      orElse: () => SearchItem(id: '', value: value),
    );
    _svc.logSelection(match, label: _showingCourses ? 'Course' : 'Staff');

    if (match.id.isNotEmpty) {
      _fetchForSelection(match.id);
    }
  }

  static const List<String> days = ['Sat','Sun','Mon','Tue','Wed','Thu'];
  void _openPicker() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor:  Color.fromRGBO(25, 14, 44, 1.0),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final controller = TextEditingController();
        List<String> current = List.of(_showingCourses ? allCourses : allStaff);

        return StatefulBuilder(
          builder: (ctx, setSheet) {
            void runFilter(String q) {
              final items = _showingCourses ? _coursesItems : _staffItems;
              final filtered = _svc.filterItems(items, q);
              setSheet(() => current = filtered.map((e) => e.value).toList());
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 12, right: 12, top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
              ),
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.7,
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      onChanged: runFilter,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Filter by text (e.g., CSEN, Aly, etc.)',
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(Icons.filter_alt, color: Colors.white70),
                        filled: true,
                        fillColor: const Color(0xFF000000),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.separated(
                        itemCount: current.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 3, color: Colors.transparent),
                        itemBuilder: (_, i) {
                          final text = current[i];
                          return ListTile(
                            shape:RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: Text(text, style: const TextStyle(color: Colors.white)),
                            onTap: () => Navigator.pop(ctx, text),
                            tileColor: const Color(0xFF000000),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (picked != null) _onSelect(picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: CustomDrawerWidget(),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromRGBO(1, 1, 1, 1),
          title: GradientTitle(text: 'Other Schedules', size: 30)
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.search),
                  label: Text(selectedItem ?? 'Select ${_showingCourses ? 'Course' : 'Staff'}'),
                  onPressed: _openPicker,
                ),
              ),
              Row(
                children: [
                  const Spacer(),
                  ChoiceChip(
                    label: const Text('Courses'),
                    selected: _showingCourses,
                    onSelected: (sel) {
                      if (!sel) return;
                      setState(() {
                        _showingCourses = true;
                        _visible = allCourses;
                        selectedItem = null;
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Staff'),
                    selected: !_showingCourses,
                    onSelected: (sel) {
                      if (!sel) return;
                      setState(() {
                        _showingCourses = false;
                        _visible = allStaff;
                        selectedItem = null;
                      });
                    },
                  ),
                  const Spacer(),
                ],
              ),


              const SizedBox(height: 20),

              SizedBox(
                height: 55,
                child: ListView.builder(
                  itemCount: dayTabs.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, idx) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DayTile(
                        color: selIndex == idx
                            ? Colors.deepPurple
                            : const Color.fromRGBO(45, 45, 45, 1),
                        day: dayTabs[idx],
                        onTap: () => setState(() => selIndex = idx),
                      ),
                    );
                  },
                ),
              ),

              if (_schedLoading) ...[
                const Center(child: CircularProgressIndicator()),
              ] else if (_schedError != null) ...[
                Center(
                  child: Text(
                    'Failed to load schedule',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),
                Text('$_schedError', style: Theme.of(context).textTheme.bodySmall),
              ] else ...[
                for (int i = 0; i < 5; i++) ...[
                  Builder(
                    builder: (context) {
                      final fullKey = _abbrToFull[dayTabs[selIndex]]!;
                      final daySlots = _data[fullKey] ?? const <ScheduleSlot>[];
                      final s = (i < daySlots.length) ? daySlots[i] : ScheduleSlot.free(i + 1);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        child: SchedTile(
                          title: s.title,
                          slotNum: s.slot,
                          course: s.course,
                          room: s.room,
                          timeStart: s.start,
                          timeEnd: s.end,
                          items: s.details,
                        ),
                      );
                    },
                  ),
                ],
                const Spacer(flex: 1),
              ]


            ],
          ),
        ),
      ),
    );
  }
}
