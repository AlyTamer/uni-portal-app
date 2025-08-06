import 'package:flutter/material.dart';

class DayTile extends StatelessWidget {
  final String day;
  final Color color;
  final VoidCallback onTap;

  const DayTile({
    super.key,
    required this.color,
    required this.day,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: EdgeInsets.zero,
        ),
        onPressed: onTap,
        child: Center(
          child: Text(
            day,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
