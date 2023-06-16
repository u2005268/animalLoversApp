import 'package:animal_lovers_app/components/longCard.dart';
import 'package:animal_lovers_app/components/shortButton.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/edit_profile.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Gap(20),
                  LongCard(
                      url: 'https://www.dvs.gov.my/index.php/pages/view/797',
                      buttonText: "DVS (Department of Veterinary Services)"),
                  Gap(20),
                  LongCard(
                      url: 'https://awa.dvs.gov.my/support',
                      buttonText:
                          "Complaint Form Regarding Animal Welfare & Abuse"),
                  Gap(20),
                  LongCard(
                      url: 'https://animalneighboursproject.org/',
                      buttonText: "Animal Neigbours Project"),
                ],
              ),
            ),
          )),
    );
  }
}
