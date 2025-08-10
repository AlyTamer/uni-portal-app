import 'package:flutter/material.dart';
import 'package:uni_portal_app/widgets/gradient_titles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class AboutMe extends StatelessWidget {
  const AboutMe({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 40, color: Colors.purple),
          onPressed: () => Navigator.of(context).pop(),
        ),

        titleSpacing: 80,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,

              children:[
             GradientTitle(text: 'About Me', size: 60),
              const SizedBox(height: 20),
          Text.rich(
              TextSpan(
                text: 'Developer: ',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 30,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: ' Aly El Anany',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurpleAccent,
                    ),
                  ),
                ],
              ),
          ),
              const SizedBox(height: 20),
              const Text(
                  'This app was developed by me , 61- MET Student, as a personal project to solve the issue of not having a unified platform for accessing university resources.',
                style:TextStyle(fontSize: 20,color: Colors.white)),
              const SizedBox(height:30),
              GradientTitle(text: 'Contact Me', size: 50),
              const SizedBox(height:15),
                Text.rich(
                  TextSpan(
                    text: 'You can find me on: \n',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                    children: [
                      TextSpan(
                        text: 'LinkedIn\n',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.parse('www.linkedin.com/in/alytamerelanany');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                      ),
                      TextSpan(
                        text: 'Github\n',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            final url = Uri.parse('https://github.com/AlyTamer');
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            }
                          },
                      ),
                      TextSpan(
                        text: 'Or You can email me at:\n',
                        children: [
                          TextSpan(text:'aly.t.elenany@gmail.com',
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),),
                        ]
                      ),


                    ],
                  ),
                ),
              const SizedBox(height: 20),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.purple, Colors.pink, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(152, 151, 151, 1.0)
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Go Back',style:TextStyle(color: Colors.black,
                    fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),

            ]
          ),
        ),
      ),
    );
  }
}
