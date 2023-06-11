import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/homepage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firebase.initializeApp();
  runApp(const CallApp());
}

class CallApp extends StatelessWidget {
  const CallApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
