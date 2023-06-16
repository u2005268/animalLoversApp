import 'package:animal_lovers_app/components/longButton.dart';
import 'package:animal_lovers_app/screens/login_or_register.dart';
import 'package:animal_lovers_app/services/google_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Gap(100),
              //logo
              Image.asset(
                'images/anp.png',
              ),
              Gap(50),
              Text(
                "Animal Lovers App",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Gap(30),
              Text(
                "Welcome!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              Gap(40),
              LongButton(
                buttonText: "Login",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginOrRegister()),
                  );
                },
              ),
              Gap(50),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 28.0),
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      "Or login with",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 28.0),
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ],
              ),
              Gap(50),
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
                        color: Colors.black.withOpacity(0.1), // Shadow color
                        spreadRadius: 2, // Spread radius
                        blurRadius: 5, // Blur radius
                        offset: Offset(0, 3), // Offset in the x and y direction
                      ),
                    ],
                  ),
                ),
              ),
              Gap(30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don’t have an account?",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(5),
                  Text(
                    "Register",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
