import 'package:flutter/material.dart';
import 'package:uni_portal_app/functions/schedule/schedule_service.dart' as svc;

class SchedTile extends StatelessWidget {
  final String title;
  final int slotNum;
  final String course;
  final String room;
  final String timeStart;
  final String timeEnd;

  final List<svc.SlotDetail>? items;

  const SchedTile({
    super.key,
    required this.title,
    required this.slotNum,
    required this.course,
    required this.room,
    required this.timeStart,
    required this.timeEnd,
    this.items,
  });
  String get _primaryTypeLetter {
    if ((items?.isEmpty ?? true)) return '';
    final t = items!.first.type.toLowerCase();
    if (t.startsWith('lec')) return 'L';
    if (t.startsWith('tut')) return 'T';
    if (t.startsWith('lab')) return 'LB';
    if (t.startsWith('prac')) return 'P';
    return '';
  }

  int get _count => items?.length ?? 0;
  bool get _hasMultiple => (items?.length ?? 0) > 1;
  String _trimType(String title){
    if(title.contains("(Lecture)")) {
      return title.replaceAll("(Lecture)", "").trim();
    } else if(title.contains("(Tutorial)")) {
      return title.replaceAll("(Tutorial)", "").trim();
    }
    else if (title.contains("(Lab)")) {
      return title.replaceAll("(Lab)", "").trim();
    }
    else if (title.contains("(Practical)")) {
      return title.replaceAll("(Practical)", "").trim();
    }
    else 
      return title;
  }
  @override
  Widget build(BuildContext context) {
    final content = Container(
      height: 75,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromRGBO(113, 0, 0, 1.0),
            Color.fromRGBO(104, 24, 131, 1.0),
            Color.fromRGBO(0, 49, 124, 1.0)
          ],
          begin: Alignment.topRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(3),
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 19, 64, 1.0),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Stack(
          children: [

            Positioned(
              left: 10, top: 10,
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.pink, Colors.transparent],
                  begin: Alignment.centerRight,
                  end: Alignment.bottomLeft,
                ).createShader(bounds),
                blendMode: BlendMode.srcIn,
                child: Text(
                  slotNum.toString(),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),

            Positioned(
              top: 5, left: 50, right: 120,
              child: Text(
                _trimType(title),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),

            Positioned(
              top: 47, left: 50, right: 120,
              child: Text(
                course,
                maxLines: 1,
                overflow: TextOverflow.visible,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),

            Positioned(
              top: 10, right: 15,
              child: Text(
                '${timeStart.isEmpty ? '' : timeStart}'
                    '${(timeStart.isNotEmpty || timeEnd.isNotEmpty) ? ' - ' : ''}'
                    '${timeEnd.isEmpty ? '' : timeEnd}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),

            Positioned(
              top: 30, right: 15,
              child: Text(
                room,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            if (_primaryTypeLetter.isNotEmpty)
              Positioned(
                left:16, bottom: 2,
                child: Text(
                    _primaryTypeLetter,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: Colors.pinkAccent
                    ),
                  ),

              ),

            if (_hasMultiple)
              Positioned(
                top:-1, right: -1.4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.redAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.expand_more, size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '+${_count - 1} more',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return _hasMultiple
        ? InkWell(onTap: () => _showDetails(context), child: content)
        : content;
  }

  void _showDetails(BuildContext context) {
    final list = items!;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0B0B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(ctx).size.height * 0.6,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Slot $slotNum — Details',
                      style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF151515),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('Room',
                              style: Theme.of(ctx).textTheme.labelLarge),
                        ),
                        Expanded(
                          child: Text('Instructor',
                              style: Theme.of(ctx).textTheme.labelLarge),
                        ),
                        Expanded(child: Text('Type', style: Theme.of(ctx).textTheme.labelLarge)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.white12),
                      itemBuilder: (_, i) {
                        final it = list[i];
                        final roomText =
                        (it.room.isNotEmpty) ? it.room : '—';
                        final instText =
                        (it.instructor.isNotEmpty) ? it.instructor : '—';

                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF121212),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(roomText,
                                    style: Theme.of(ctx).textTheme.bodyMedium),
                              ),
                              Expanded(
                                child: Text(instText,
                                    style: Theme.of(ctx).textTheme.bodyMedium),
                              ),
                              Expanded(child: Text((it.type.isNotEmpty) ? it.type : '—',
                                  style: Theme.of(ctx).textTheme.bodyMedium)),
                            ],
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
      },
    );
  }
}