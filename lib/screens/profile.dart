import 'package:animal_lovers_app/components/shortButton.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/edit_profile.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Color(0xFF0F281D),
            ),
            onPressed: () {
              //navigate to profile page
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => EditProfilePage()));
            },
          )
        ],
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
          child: Center(
            child: Column(
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
                Text(
                  "Peimun01",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Gap(5),
                Text(
                  "peimun030601@gmail.com",
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                ),
                Gap(10),
                Container(
                  padding: EdgeInsets.all(20),
                  margin: EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Color(0xFF213221),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Text(
                    "Embracing the beauty of all creatures, I find solace and inspiration in the unconditional love of animals.",
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                Gap(40),
                Text(
                  "My Favourites",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                Gap(10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: ShortButton(
                          buttonText: "Species",
                          isTapped: false,
                          onTap: () {},
                        ),
                      ),
                      Gap(20),
                      Flexible(
                        child: ShortButton(
                          buttonText: "Observation",
                          isTapped: false,
                          onTap: () {},
                        ),
                      ),
                      Gap(20),
                      Flexible(
                        child: ShortButton(
                          buttonText: "News",
                          isTapped: true,
                          onTap: () {},
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
