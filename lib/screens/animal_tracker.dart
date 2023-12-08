import 'package:animal_lovers_app/screens/observation.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
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
    //navigate to donate page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DonatePage()));
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
        appBar: CustomAppBar(
          titleText: "Animal Tracker",
          actionWidgets: [
            IconButton(
              icon: Icon(
                Icons.add_circle_outline_outlined,
                color: Styles.primaryColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ObservationPage()));
              },
            ),
          ],
        ),
        drawer: SideBar(),
        bottomNavigationBar: BottomBar(),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Container(
              color: Colors.white,
            ),
          ),
        ));
  }
}
