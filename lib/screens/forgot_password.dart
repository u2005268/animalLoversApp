import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/customizedTextfield.dart';
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
  void showErrorMessage(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            width: 200.0,
            height: 200.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSuccess
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 80.0,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                Gap(20.0),
                Text(
                  isSuccess ? 'Done' : 'Error',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                Gap(20.0),
                Text(
                  isSuccess ? message : message,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      showErrorMessage("Password reset link sent! Check your email.", true);
    } on FirebaseAuthException catch (e) {
      print(e);
      if (_emailController.text.trim().length == 0) {
        showErrorMessage("Please fill in your email.", false);
      } else if (e.code == 'user-not-found') {
        //show wrong email error
        showErrorMessage("User not found.", false);
      } else {
        showErrorMessage(e.message.toString(), false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.secondaryColor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left_sharp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: Styles.gradientBackground(),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
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
    );
    ;
  }
}
