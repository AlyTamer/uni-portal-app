import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/day_tile_widget.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';

import '../widgets/schedule_item_widget.dart';
class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  static const List<String> days = [
    'Sat','Sun','Mon','Tue','Wed','Thu'
  ];
  int selIndex = 0;
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:  Colors.transparent,
        leading:IconButton(
          icon: Icon(Icons.arrow_back, size:40,color:Colors.purple),
          onPressed: (){
            Navigator.of(context).pop();
          },
        ),
        title: Center(child: GradientTitle(text: 'Schedule',size:32)),
        titleSpacing: 80,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          
          children:[
            SizedBox(
              height: 55,
              child: ListView.builder(
                itemCount: days.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (BuildContext context,idx) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DayTile(
                        color: selIndex==idx?Colors.deepPurple:Color.fromRGBO(45,45,45,1),
                        day: days[idx],
                        onTap: (){
                          setState(() {
                            selIndex=idx;
                          });
                        }),
                  );
                },

              ),
            ),
            const SizedBox(height:16),
            SchedTile(
              title: 'CS101',
              slotNum: 1,
              course: 'Computer Science',
              room: 'C4.101',
              timeStart: '8:15 AM',
              timeEnd: '9:45 AM',
            ),
            const Spacer(),
            SchedTile(
              title: 'CS202',
              slotNum: 2,
              course: 'Data Structures',
              room: 'C4.202',
              timeStart: '10:00 AM',
              timeEnd: '11:30 AM',
            ),
            const Spacer(),
            SchedTile(
              title: 'CS303',
              slotNum: 3,
              course: 'Algorithms',
              room: 'C2.403',
              timeStart: '11:45 AM',
              timeEnd: '1:15 PM',
            ),
            const Spacer(),
            SchedTile(
              title: 'CS504',
              slotNum: 4,
              course: 'Operating Systems',
              room: 'D4.307',
              timeStart: '1:45 PM',
              timeEnd: '3:15 PM',
            ),
            const Spacer(),
            SchedTile(
              title: 'CS605',
              slotNum: 5,
              course: 'Database Systems',
              room: 'B1.222',
              timeStart: '3:45 PM',
              timeEnd: '5:15 PM',
            ),
            const Spacer(flex:3),

          ],
        ),
      ),
    );
  }
}
