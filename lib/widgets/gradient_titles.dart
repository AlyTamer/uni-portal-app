import 'package:flutter/material.dart';
class GradientTitle extends StatelessWidget {
  final String text;
  final double size;
  const GradientTitle ({super.key, required this.text, required this.size});

  @override
  Widget build(BuildContext context) {
    return Align(
    alignment: Alignment.centerLeft,
    child: ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [Colors.purpleAccent, Colors.pinkAccent, Colors.blueAccent],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
         fontSize:size,

        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,

      ),
    ),
    );
  }
}
