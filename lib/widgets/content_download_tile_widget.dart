import 'package:flutter/material.dart';

class DownloadTile extends StatelessWidget {
  final String title;
  final String href;
  final VoidCallback onDownload;
  final bool isDownloaded;
  const DownloadTile({super.key,required this.onDownload, required this.title, required this.href,  this.isDownloaded=false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        leading: Icon(Icons.arrow_right_sharp, size: 50, color: Colors.pink),
        title: Text('$title'),
        trailing:IconButton(
           onPressed: onDownload,
          icon: Icon( isDownloaded? Icons.open_in_new:
              Icons.download,
              size: 35,
              color: isDownloaded ? Colors.green: Colors.blueAccent),
        ),
        tileColor: Color.fromRGBO(12, 12, 12, 1.0),
      ),
    );
  }
}
