import 'package:flutter/material.dart';

class DownloadTile extends StatelessWidget {
  final String title;
  const DownloadTile({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(Icons.arrow_right_sharp, size: 50, color: Colors.pink),
        title: Text('PlaceHolder $title'),
        trailing:IconButton(
           onPressed: () {  },
          icon: Icon(
              Icons.download,
              size: 35,
              color: Colors.blueAccent),
        ),
        tileColor: Color.fromRGBO(12, 12, 12, 1.0),
      ),
    );
  }
}
