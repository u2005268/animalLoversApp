import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/auth_page.dart';
import 'package:animal_lovers_app/screens/login.dart';
import 'package:animal_lovers_app/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:animal_lovers_app/screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Animal Lovers App',
        theme: ThemeData(
          primarySwatch: Colors.grey,
        ),
        home: AuthPage());
  }
}
