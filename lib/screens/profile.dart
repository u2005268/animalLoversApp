import 'package:animal_lovers_app/components/bottom_bar.dart';
import 'package:animal_lovers_app/components/shortButton.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/edit_profile.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? bio;
  String? photoUrl;
  final currentUser = FirebaseAuth.instance.currentUser!;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userId = currentUser.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data();
        setState(() {
          username = userData?['username'];
          bio = userData?['bio'];
          photoUrl = userData?['photoUrl'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  String getBioText() {
    if (bio == null || bio!.isEmpty) {
      return 'You do not have any bio yet. Do add it by tapping the edit icon button';
    }
    return bio!;
  }

  String getPhotoUrl() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return 'assets/images/user.png'; // Replace with the asset image path
    }
    return photoUrl!;
  }

  void navigateDonate() {
    // Navigate to donate page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DonatePage()),
    );
  }

  void navigateInfo() {
    // Pop drawer
    Navigator.pop(context);

    // Navigate to info page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => InfoPage()),
    );
  }

  void navigateProfile() {
    // Pop drawer
    Navigator.pop(context);

    // Navigate to profile page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProfilePage()),
    );
  }

  void navigateEditProfile() async {
    // Navigate to edit profile page
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          username: username ?? '',
          email: currentUser.email!,
          bio: bio ?? '',
          photoUrl: photoUrl ?? '',
          onProfileUpdated: handleProfileUpdated,
        ),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        bio = updatedUserData['bio'];
      });
    }
  }

  void handleProfileUpdated(String updatedBio) {
    setState(() {
      bio = updatedBio;
    });
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
            onPressed: navigateEditProfile,
          )
        ],
      ),
      drawer: SideBar(
        onDonateTap: navigateDonate,
        onInfoTap: navigateInfo,
        onProfileTap: navigateProfile,
      ),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
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
            ),
            child: Center(
              child: Column(
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: photoUrl != null && photoUrl!.isNotEmpty
                          ? Image.network(
                              photoUrl!,
                              // Specify any additional properties for the network image if needed
                            )
                          : Image.asset(
                              'images/user.png', // Replace with the asset image path
                              // Specify any additional properties for the asset image if needed
                            ),
                    ),
                  ),
                  Text(
                    username ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(5),
                  Text(
                    currentUser.email!,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(10),
                  Container(
                    width: 450,
                    height: 80,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Color(0xFF213221),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      getBioText(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Gap(40),
                  Text(
                    "My Favorites",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 35.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 90,
                          child: ShortButton(
                            buttonText: "Species",
                            isTapped: false,
                            onTap: () {},
                          ),
                        ),
                        Gap(20),
                        Container(
                          width: 90,
                          child: ShortButton(
                            buttonText: "Observation",
                            isTapped: false,
                            onTap: () {},
                          ),
                        ),
                        Gap(20),
                        Container(
                          width: 90,
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
            ),
          ),
        ),
      ),
    );
  }
}
