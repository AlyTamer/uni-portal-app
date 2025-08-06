import 'package:flutter/material.dart';
class GradeTile extends StatelessWidget {
  final String name;
  final String score;
  final String subtext;
  const GradeTile({super.key,
  required this.name,
    required this.score,
    required this.subtext,});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
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
      borderRadius: BorderRadius.circular(12), // rounded outer border
      ),
      padding: const EdgeInsets.all(3), // thickness of the outline
      child: Container(
      decoration: BoxDecoration(
      color:  Colors.black,
      borderRadius: BorderRadius.circular(9), // slightly smaller
      ),
        child:Stack(
          children: [
            Positioned(
              top: 10,
                left: 10,
                child: Text(name,style: Theme.of(context).textTheme.titleMedium)
            ),
            Positioned(
                top: 40,
                left: 10,
                child: Text(subtext,style: Theme.of(context).textTheme.bodyMedium)
            ),
            Positioned(
              top: 10,
              right:10,
              child: Text(score,
                  style: Theme.of(context).textTheme.titleLarge
            ),
            ),
          ],
        )
      ),
      ),
    );
  }
}
