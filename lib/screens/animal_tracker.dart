import 'package:animal_lovers_app/screens/bottom_bar.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimalTracker extends StatefulWidget {
  AnimalTracker({Key? key}) : super(key: key);

  @override
  State<AnimalTracker> createState() => _AnimalTrackerState();
}

class _AnimalTrackerState extends State<AnimalTracker> {
  final user = FirebaseAuth.instance.currentUser!;

  void navigateDonate() {
    //navigate to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const ProfilePage()));
  }

  void navigateInfo() {
    //pop drawer
    Navigator.pop(context);

    //navigate to info page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InfoPage()));
  }

  void navigateProfile() {
    //pop drawer
    Navigator.pop(context);

    //navigate to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black), // Remove the shadow
          title: Text(
            "Animal Tracker",
            style: TextStyle(
              color: Colors.black, // Set the text color to black
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_outlined,
                color: Color(0xFF0F281D),
              ),
              onPressed: () {},
            )
          ], // Set the icon color to black,
        ),
        drawer: SideBar(
            onDonateTap: navigateDonate,
            onInfoTap: navigateInfo,
            onProfileTap: navigateProfile),
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Container(
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
          )),
        ));
  }
}
