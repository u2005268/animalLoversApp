import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/login.dart';
import 'package:animal_lovers_app/screens/splash_screen.dart';
import 'package:animal_lovers_app/screens/login_or_register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            //user is logged in
            if (snapshot.hasData) {
              return AnimalTracker();
            }
            //user is not logged in
            else {
              //splashscreen or loginOrRegister
              return LoginOrRegister();
            }
          }),
    );
  }
}
