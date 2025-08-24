import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/day_tile_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';
import '../../widgets/schedule_item_widget.dart';
import 'package:uni_portal_app/functions/schedule/schedule_service.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<String> days = ['Sat','Sun','Mon','Tue','Wed','Thu'];
  int selIndex = 0;
  final _svc = ScheduleService();
  StreamSubscription<void>? _sub;

  Map<String, List<ScheduleSlot>> _data = {
    for (final d in days) d: List.generate(5, (i) => ScheduleSlot.free(i + 1)),
  };
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _bootstrapSWR();

    _sub = _svc.groupScheduleRefreshed.listen((_) async {
      final map = await _svc.getCachedGroupSchedule();
      if (!mounted) return;
      setState(() => _data = map);
    });
  }
  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
  Future<void> _bootstrapSWR() async {
    try {
      final map = await _svc.fetchScheduleSWR(); // cache now; refresh in bg
      if (!mounted) return;
      setState(() {
        _data = map;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.purple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(child: GradientTitle(text: 'Schedule', size: 29)),
        titleSpacing: 80,
        actions: [
          IconButton(onPressed: (){
            showModalBottomSheet(context: context, builder: (context){
              return SingleChildScrollView(
                  child:Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const GradientTitle(text: "Schedule Time Slots", size: 22),
                          const SizedBox(height: 24),
                          Text(
                            "For Engineering, Management, & Business Informatics",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Table(
                            border: TableBorder.all(color: Colors.white),
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                              4: FlexColumnWidth(),
                            },
                            children: const [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("First Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Second Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Third Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Fourth Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Fifth Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("8:15 - 9:45", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("10:00 - 11:30", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("11:45 - 1:15", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("1:45 - 3:15", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("3:45 - 5:15", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            "For Pharmacy, Applied Arts, & Law",
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Table(
                            border: TableBorder.all(color: Colors.white),
                            columnWidths: const {
                              0: FlexColumnWidth(),
                              1: FlexColumnWidth(),
                              2: FlexColumnWidth(),
                              3: FlexColumnWidth(),
                              4: FlexColumnWidth(),
                            },
                            children: const [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("First Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Second Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Third Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Fourth Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("Fifth Slot", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("8:15 - 9:45", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("10:00 - 11:30", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("12:00 - 1:30", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("1:45 - 3:15", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.0), // Padding added here
                                    child: Text("3:45 - 5:15", textAlign: TextAlign.center, style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      )
                  )
              );
            });
          }, icon: const Icon(Icons.info_outline,color: Colors.lightBlue,))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 55,
              child: ListView.builder(
                itemCount: days.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, idx) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DayTile(
                      color: selIndex == idx
                          ? Colors.deepPurple
                          : const Color.fromRGBO(45, 45, 45, 1),
                      day: days[idx],
                      onTap: () {
                        setState(() => selIndex = idx);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            if (_loading) ...[
              const Center(child: CircularProgressIndicator()),
            ] else if (_error != null) ...[
              Center(
                child: Text(
                  'Failed to load schedule',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 8),
              Text('$_error', style: Theme.of(context).textTheme.bodySmall),
            ] else ...[
              for (int i = 0; i < 5; i++) ...[
                Builder(
                  builder: (context) {
                    final dayKey = days[selIndex];
                    final s = _data[dayKey]![i];
                    return SchedTile(
                      title: s.title,
                      slotNum: s.slot,
                      course: s.course,
                      room: s.room,
                    );
                  },
                ),
                if (i < 4) const Spacer(),
              ],
              const Spacer(flex: 3),
            ],
          ],
        ),
      ),
    );
  }
}
