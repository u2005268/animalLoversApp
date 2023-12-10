import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/shortButton.dart';
import 'package:animal_lovers_app/screens/edit_profile.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
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
        photoUrl = updatedUserData['photoUrl'];
      });
    }
  }

  void handleProfileUpdated(String? updatedBio, String? updatedPhotoUrl) {
    setState(() {
      bio = updatedBio;
      photoUrl = updatedPhotoUrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
        actionWidgets: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Styles.primaryColor,
            ),
            onPressed: navigateEditProfile,
          )
        ],
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[400] ?? Colors.transparent,
                        width: 1.0, // Customize the border width here
                      ),
                    ),
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
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      getBioText(),
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
