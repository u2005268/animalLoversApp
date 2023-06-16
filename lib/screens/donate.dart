import 'package:animal_lovers_app/components/shortButton.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "Info",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Set the icon color to black,
      ),
      drawer: SideBar(
          onDonateTap: navigateDonate,
          onInfoTap: navigateInfo,
          onProfileTap: navigateProfile),
      backgroundColor: Colors.transparent,
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
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Container(
                child: Column(
                  children: [
                    Image.asset(
                      'images/user.png',
                      height: 240,
                      fit: BoxFit.cover,
                    ),
                    Text(
                      "Donate to make an impact on wildlife",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 90,
                              height: 90,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  'images/user.png',
                                ),
                              ),
                            ),
                            Gap(2),
                            Text(
                              "Langur Project Penang",
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        ShortButton(
                            onTap: () {}, buttonText: "Donate", isTapped: false)
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
