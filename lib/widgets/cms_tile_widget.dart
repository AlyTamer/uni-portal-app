import 'package:flutter/material.dart';
class CmsWidget extends StatelessWidget {
  final String title;
  const CmsWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(0),
        ),
        onPressed: (){},
        child: ListTile(
          leading: Icon(Icons.arrow_right_sharp,color: Colors.white,size: 50,),
          title: Align(child: Text(title.toUpperCase(),style: Theme.of(context).textTheme.titleLarge,)),
          tileColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),


        ),
      ),
    );
  }
}
