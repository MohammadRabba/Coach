import 'package:coatch/controller/loginController.dart';
import 'package:coatch/view/auth/login.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // مهم جدًا!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // await FirebaseAppCheck.instance.activate(
  //   // You can also provide a custom token provider or other settings here
  //   androidProvider:
  //       AndroidProvider.debug, // Or AndroidProvider.debug if testing
  // );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '3D Viewer',
      home: LoginScreen(
        controller: LoginController(),
      ),
    );
  }
}
