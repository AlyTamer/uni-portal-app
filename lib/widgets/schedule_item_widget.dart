import 'package:flutter/material.dart';

class SchedTile extends StatelessWidget {
  final String title;
  final int slotNum;
  final String course;
  final String room;
  final String timeStart;
  final String timeEnd;
  const SchedTile({super.key,
    required this.title,
    required this.slotNum,
    required this.course,
    required this.room,
    required this.timeStart,
    required this.timeEnd,

  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              left: 10,
              top:10,
              child: ShaderMask(shaderCallback: (bounds){
                return const LinearGradient(
                  colors: [ Colors.pink, Colors.transparent],
                  begin: Alignment.centerRight,
                  end: Alignment.bottomLeft,
                ).createShader(bounds);
              },
                blendMode: BlendMode.srcIn,
              child:Text(slotNum.toString(),
                  style:Theme.of(context).textTheme.titleLarge),),
            ),
            Positioned(
              top:5,
              left: 50,
                child: Text(title,
                    style:Theme.of(context)
                        .textTheme
                        .titleMedium),
            ),
            Positioned(
              top:30,
              left: 50,
              child: Text(course,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium),
            ),
            Positioned(
              top: 10,
              right: 15,
              child: Text(timeStart + ' - ' + timeEnd,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium),
            ),
            Positioned(
              top: 30,
              right: 15,
              child: Text(room,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium),
            ),
          ],
        ),
      ),
    );
  }
}
