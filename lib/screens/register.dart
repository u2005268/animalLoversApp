import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customizedTextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({Key? key, required this.onTap}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //text editing controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  //register user method
  Future registerUser() async {
    //loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    try {
      if (_emailController.text.trim().length == 0 ||
          _passwordController.text.trim().length == 0 ||
          _confirmPasswordController.text.trim().length == 0 ||
          _usernameController.text.trim().length == 0) {
        Navigator.pop(context);
        showErrorMessage("Please fill all the details.");
      }
      //check if the password same with confirm password
      else if (_passwordController.text.trim() ==
          _confirmPasswordController.text.trim()) {
        //create user
        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());
        final userId = userCredential.user!.uid;

        //pop the loading circle
        Navigator.pop(context);
        // Add user data to Firestore
        createUsersDoc(userId, _usernameController.text.trim(),
            _emailController.text.trim(), "");
      } else {
        Navigator.pop(context);
        //show error message
        showErrorMessage("Passwords don't match");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        //show weak password error
        showErrorMessage("The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        //show account exist error
        showErrorMessage("The account already exists for that email.");
      } else {
        //show other error
        showErrorMessage(e.message.toString());
      }
    }
  }

  Future createUsersDoc(
    String userId,
    String username,
    String email,
    String bio,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).set({
      'username': username,
      'email': email,
      'bio': bio,
    });
  }

  //error message popup
  void showErrorMessage(String message) {
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
                  Icons.cancel_outlined,
                  size: 80.0,
                  color: Colors.red,
                ),
                SizedBox(height: 20.0),
                Text(
                  'Error',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  message,
                  textAlign: TextAlign.center,
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: Styles.gradientBackground(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(10),
                  //logo
                  Image.asset(
                    'images/anp.png',
                  ),
                  Gap(20),
                  Text(
                    "Register",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  Gap(10),
                  Text(
                    "Create your new account",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(30),
                  //username
                  CustomizedTextField(
                    icon: Icon(Icons.person),
                    controller: _usernameController,
                    hintText: 'Username',
                    obsureText: false,
                  ),
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
                  CustomizedTextField(
                    icon: Icon(Icons.lock_sharp),
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    obsureText: true,
                  ),
                  Gap(5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "By signing up, you’ve agreed to our terms of use and privacy notice.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  Gap(20),
                  LongButton(
                    buttonText: "Register",
                    onTap: registerUser,
                  ),
                  Gap(30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                      ),
                      Gap(5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          "Login",
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
