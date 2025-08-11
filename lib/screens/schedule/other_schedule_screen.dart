import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/custom_drawer_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';

import '../../functions/schedule/schedule_service.dart';
class OtherSchedules extends StatefulWidget {
  const OtherSchedules({super.key});

  @override
  State<OtherSchedules> createState() => _OtherSchedulesState();
}

class _OtherSchedulesState extends State<OtherSchedules> {
  final _svc = ScheduleService();

  List<SearchItem> _coursesItems = [];
  List<SearchItem> _staffItems = [];

  List<String> allCourses = [];
  List<String> allStaff = [];

  List<String> _visible = [];
  bool _showingCourses = true;

  String? selectedItem;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadSearchLists();
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
              ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [
                        Colors.purpleAccent,
                        Colors.pink,
                        Colors.lightBlue,
                      ],
                      begin: Alignment.topRight,
                      end: Alignment.centerLeft,
                    ).createShader(
                        Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(65, 65, 65, 1),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  height: 70,
                  width: double.infinity,
                  child: Center(
                    child: DropdownButton<String>(
                      value: selectedItem,
                      hint: const Text('Select Course/Staff'),
                      isExpanded: true,
                      dropdownColor: Colors.black,
                      items: _visible
                          .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) _onSelect(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: _visible.length,
                  itemBuilder: (context, idx) {
                    final text = _visible[idx];
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ListTile(
                        title: Text(text, style: Theme.of(context).textTheme.titleMedium),
                        leading: const Icon(Icons.arrow_right, color: Colors.deepPurple, size: 60),
                        tileColor: const Color.fromRGBO(10, 10, 10, 1),
                        onTap: () => _onSelect(text),
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
