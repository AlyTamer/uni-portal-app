import 'package:flutter/material.dart';

class InteractiveIcon extends StatelessWidget {
  final IconData icon;
  final String iconName;
  final Color iconColor;
  final double iconSize;

  const InteractiveIcon({
    super.key,
    required this.icon,
    required this.iconName,
    required this.iconColor,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: iconColor == Colors.transparent ? Colors.white : iconColor,
    );


    if (iconColor == Colors.transparent) {
      iconWidget = ShaderMask(
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Color.fromRGBO(113, 0, 0, 1.0),
            Color.fromRGBO(104, 24, 131, 1.0),
            Color.fromRGBO(0, 49, 124, 1.0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(bounds),
        blendMode: BlendMode.srcIn,
        child: Icon(
          icon,
          size: iconSize,
          color: Colors.white,
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 1.0),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: iconWidget,
        ),
        const SizedBox(height: 6),
        Text(
          iconName,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
