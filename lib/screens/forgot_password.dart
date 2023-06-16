import 'package:animal_lovers_app/components/longButton.dart';
import 'package:animal_lovers_app/components/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  //text editing controllers
  final _emailController = TextEditingController();
  //error message popup
  void showErrorMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(message),
          );
        });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      showErrorMessage("Password rest link sent! Check your email.");
    } on FirebaseAuthException catch (e) {
      print(e);
      if (_emailController.text.trim().length == 0) {
        showErrorMessage("Please fill in your email.");
      } else {
        showErrorMessage(e.message.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3646, 0.9062, 1.0],
            colors: [
              Colors.white,
              Colors.white,
              Color.fromRGBO(182, 255, 182, 0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(80),
                  //logo
                  Image.asset(
                    'images/anp.png',
                  ),
                  Gap(20),
                  Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Gap(10),
                  Text(
                    "Please enter your email to verify your identity.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(5),
                  Text(
                    "We will send you a password reset link.",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(30),
                  //email
                  CustomizedTextField(
                    icon: Icon(Icons.email),
                    controller: _emailController,
                    hintText: 'Email',
                    obsureText: false,
                  ),
                  Gap(15),
                  LongButton(
                    buttonText: "Submit",
                    onTap: passwordReset,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    ;
  }
}
