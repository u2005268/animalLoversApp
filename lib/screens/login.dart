import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customizedTextfield.dart';
import 'package:animal_lovers_app/screens/forgot_password.dart';
import 'package:animal_lovers_app/services/google_auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';

class LoginPage extends StatefulWidget {
  final Function()? onTap;
  const LoginPage({Key? key, this.onTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //log user in method
  void logUserIn() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
    try {
      if (_emailController.text.trim().length == 0 ||
          _passwordController.text.trim().length == 0) {
        Navigator.pop(context);
        showErrorMessage("Please fill all the details.");
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim());
        //pop the loading circle
        Navigator.pop(context);

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AnimalTracker()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'user-not-found') {
        //show wrong email error
        showErrorMessage("User not found.");
      } else if (e.code == 'wrong-password') {
        //show wrong password error
        showErrorMessage("Wrong Password");
      } else {
        //show other error
        showErrorMessage(e.message.toString());
      }
    }
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Styles.gradientBackground(),
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
                    "Welcome back",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Gap(10),
                  Text(
                    "Login to your account",
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
                  //password
                  CustomizedTextField(
                    icon: Icon(Icons.lock_sharp),
                    controller: _passwordController,
                    hintText: 'Password',
                    obsureText: true,
                  ),
                  Gap(5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ForgotPasswordPage()),
                            );
                          },
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Styles.primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(20),
                  LongButton(
                    buttonText: "Login",
                    onTap: logUserIn,
                  ),
                  Gap(20),
                  GestureDetector(
                    onTap: () {
                      GoogleAuth().signInWithGoogle();
                    },
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Image.asset('images/google.png'),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withOpacity(0.1), // Shadow color
                            spreadRadius: 2, // Spread radius
                            blurRadius: 5, // Blur radius
                            offset:
                                Offset(0, 3), // Offset in the x and y direction
                          ),
                        ],
                      ),
                    ),
                  ),
                  Gap(20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don’t have an account?",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      Gap(5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Register",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Styles.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
