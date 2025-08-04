import 'package:flutter/material.dart';
class GradientTitle extends StatelessWidget {
  final String text;
  const GradientTitle ({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft,
    child: ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.purple, Colors.pink, Colors.blueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
    );
  }
}
