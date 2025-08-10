import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';

import '../../functions/schedule/schedule_service.dart';
import '../about_me_screen.dart';
import '../login_screen.dart';
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
        drawer: Drawer(
          backgroundColor: const Color.fromRGBO(11, 11, 11, 1),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              SizedBox(
                width: 150,
                height: 70,
                child: DrawerHeader(
                  decoration: const BoxDecoration(color: Colors.black87),
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.purple, Colors.pink, Colors.blueAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                    child: Text(
                      'Menu',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
              ListTile(
                  leading: const Icon(Icons.home, color: Colors.pinkAccent),
                  title: const Text('Home'),
                  onTap: () => Navigator.popUntil(context, (route) => route.isFirst)
              ),
              ListTile(
                leading: const Icon(Icons.manage_search, color: Colors.deepPurpleAccent),
                title: const Text('Other Schedules'),
                onTap: () {
                  //TODO implement view other schedules
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                  leading: const Icon(Icons.search, color: Colors.purpleAccent),
                  title: const Text('Previous CMS'),
                  onTap: () {
                    //TODO implement view previous courses CMS Navigation
                  }
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                  leading: const Icon(Icons.gamepad, color: Colors.blueAccent),
                  title: const Text('Arcade'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Arcade feature Coming Soon!\nNo Promises ;)'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                  leading: const Icon(Icons.calculate_outlined, color: Colors.deepPurpleAccent),
                  title: const Text('GPA Calculator'),
                  onTap: () {
                    //TODO implement Gpa Calculator Capability
                  }
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.025),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.white),
                title: const Text('About The Dev'),
                onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AboutMe(),
                    ),
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.3),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout'),
                onTap: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  await prefs.remove('savedUsername');
                  await prefs.remove('savedPassword');

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
