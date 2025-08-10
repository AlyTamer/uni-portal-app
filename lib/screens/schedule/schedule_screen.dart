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

  Map<String, List<ScheduleSlot>> _data = {
    for (final d in days) d: List.generate(5, (i) => ScheduleSlot.free(i + 1)),
  };
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final svc = ScheduleService();
      final map = await svc.fetchSchedule();
      if (!mounted) return;
      setState(() {
        _data = map;
        _loading = false;
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
        title: Center(child: GradientTitle(text: 'Schedule', size: 32)),
        titleSpacing: 80,
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
                      timeStart: s.start,
                      timeEnd: s.end,
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
