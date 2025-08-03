import 'package:flutter/material.dart';
class InteractiveIcon  extends StatelessWidget {
  final IconData icon;
  final String iconName;
  final Color iconColor;
  final double iconSize;
  const InteractiveIcon ({super.key,
  required this.icon,
  required this.iconName, required this.iconColor,
  required this.iconSize}) ;



  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 0, 0, 1.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Icon(icon,size: iconSize,color: iconColor ?? Colors.white,)
        ),
        const SizedBox(height:6),
        Text('$iconName',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),),
      ],
    );

  }
}
