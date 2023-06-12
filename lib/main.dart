import 'package:call_app_flutter/pages/login.dart';
import 'package:call_app_flutter/pages/register.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Localstorer.setPrefs();
  bool isLoggedIn = await Localstorer.getLoggedInStatus();
  await Firebase.initializeApp();
  if (isLoggedIn) {
    Localstorer.loadCurrentUser();
  }
  runApp(CallApp(isLoggedIn));
}

class CallApp extends StatelessWidget {
  const CallApp(this.isLoggedIn, {super.key});
  final bool isLoggedIn;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        LoginPage.id: (context) => const LoginPage(),
        RegisterPage.id: (context) => const RegisterPage(),
        HomePage.id: (context) => const HomePage(),
      },
      debugShowCheckedModeBanner: false,
      home: isLoggedIn ? const HomePage() : const LoginPage(),
    );
  }
}
