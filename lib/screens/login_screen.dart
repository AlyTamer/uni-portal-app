import 'package:flutter/material.dart';
import 'package:uni_portal_app/screens/main_screen.dart';
import '../functions/mailbox_webview.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../functions/webview_util.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  String? usernameError;
  String? passwordError;
  late String username;
  late String password;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool validateInput(){
    final inputUsername = _usernameController.text;
    final inputPassword = _passwordController.text;
    usernameError=null;
    passwordError=null;
    if (inputUsername.isEmpty || inputPassword.isEmpty) {
      setState(() {
        usernameError = "Username cannot be empty.";
        passwordError = "Password cannot be empty.";
      });
      return false;
    }
    if(!inputUsername.contains('.')||!RegExp(r"^[a-zA-Z\-'.]+$").hasMatch(inputUsername))
    {
      setState(() {
        usernameError = "Invalid Username Format.";
      });
      return false;
    }
    if (usernameError == null && passwordError == null) {
      username = inputUsername;
      password = inputPassword;
    }
    return usernameError == null && passwordError == null;
  }
  Future<void> tryLoginAndFetchInbox() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedUsername', username);
      await prefs.setString('savedPassword', password);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            username: username,
            password: password,
          ),
        ),
      );
    } catch (e) {
      print('Login or navigation failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login failed. Please check your credentials.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      final savedUsername = prefs.getString('savedUsername') ?? "NO_USERNAME";
      final savedPassword = prefs.getString('savedPassword') ?? "NO_PASSWORD";

      if (savedUsername != "NO_USERNAME" && savedPassword != "NO_PASSWORD") {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              username: savedUsername,
              password: savedPassword,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Spacer(),
      Center(
        child: ShaderMask(shaderCallback: (bounds) =>
          LinearGradient(colors: [Colors.purple, Colors.pink],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: RichText(text: TextSpan(text: 'UHub',
          style: TextStyle(color: Colors.white,
            fontSize: 140, fontWeight: FontWeight.bold,),
        ),
        ),
      ),
      ),
      const SizedBox(height: 32),
      Align(alignment: Alignment.centerLeft,
          child: Text('Enter Your Username', style: Theme
              .of(context)
              .textTheme
              .titleMedium,)),

      const SizedBox(height: 16),
      TextField(
        controller: _usernameController,
        decoration: InputDecoration(
          errorText: usernameError,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(
            color: Color.fromRGBO(213, 111, 172, 1.0), width: 2.0),),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.purple, width: 2.0),),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),

        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),),

        hintText: 'Enter Your Username',),),
      const SizedBox(height: 16),
      Align(alignment: Alignment.centerLeft,
          child: Text('Enter Your Password', style: Theme
              .of(context)
              .textTheme
              .titleMedium,)),
      const SizedBox(height: 16),
      TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          errorText: passwordError,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(
            color: Color.fromRGBO(213, 111, 172, 1.0), width: 2.0),),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.purple, width: 2.0),),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),

        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
          borderSide: BorderSide(color: Colors.red, width: 2.0),)
        ,
        hintText: 'Enter Your Password',
     ),),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll<Color>(Colors.green),
            ),
              onPressed: () async {
                if (validateInput()) {
                  await clearWebViewSession();
                  tryLoginAndFetchInbox();
                }
              }, child: Text("Login", style: TextStyle(fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,),)),
        ),
        ElevatedButton(style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all<Color>(
              Color.fromRGBO(213, 111, 172, 1.0)),),
            onPressed: () {
              showDialog(context: context, builder: (context) =>
                  AlertDialog(backgroundColor: Color.fromRGBO(50, 28, 89, 1.0),
                    title: Text("Check These Things!", style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge,),
                    content: Text(
                      "1- Make sure you have a stable internet connection.\n"
                          "2- Ensure your username and password are correct.\n"
                          "3- If you forgot your password, use the 'Forgot Password' option.",
                      style: TextStyle(fontSize: 22),),
                    actions: [TextButton(onPressed: () {
                      Navigator.of(context).pop();
                    }, child: Text("OK",),),
                    ],));
            },
            child: Text("Trouble Logging In?", style: TextStyle(fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,),)),
const Spacer(flex:2)

        ],),));
  }
}