import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uni_portal_app/widgets/custom_drawer_widget.dart';

import '../../widgets/gradient_titles.dart';
import '../about_me_screen.dart';
import '../login_screen.dart';
class TranscriptScreen extends StatelessWidget {
  const TranscriptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawerWidget(),
      appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: const Color.fromRGBO(1, 1, 1, 1),
          title: GradientTitle(text: 'Transcript', size: 30)
      ),
    );
  }
}
