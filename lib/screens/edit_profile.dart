import 'package:animal_lovers_app/components/longButton.dart';
import 'package:animal_lovers_app/components/underlineTextfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String bio;
  final String? photoUrl;
  final Function(String bio) onProfileUpdated;

  const EditProfilePage({
    Key? key,
    required this.username,
    required this.email,
    required this.bio,
    this.photoUrl,
    required this.onProfileUpdated,
  }) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _bioController;
  late TextEditingController _changePasswordController;

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(message),
        );
      },
    );
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text);
      showErrorMessage("Password reset link sent! Check your email.");
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.message.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _bioController = TextEditingController(text: widget.bio);
    _changePasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _changePasswordController.dispose();
    super.dispose();
  }

  void updateProfileData(String updatedBio) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);
        await userRef.update({
          'bio': updatedBio,
        });
      }
      widget.onProfileUpdated(updatedBio);
      Navigator.pop(context);
    } catch (error) {
      showErrorMessage('Failed to update profile data. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFD7FFD7),
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
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: widget.photoUrl != null &&
                                  widget.photoUrl!.isNotEmpty
                              ? Image.network(
                                  widget.photoUrl!,
                                  // Specify any additional properties for the network image if needed
                                )
                              : Image.asset(
                                  'images/user.png',
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(0),
                          child: Container(
                            width: 25,
                            height: 25,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              color: Color(0xFFD7FFD7),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 2,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(5),
                  Text(
                    _usernameController.text,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(5),
                  Text(
                    _emailController.text,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(20),
                  UnderlineTextfield(
                    controller: _bioController,
                    hintText: "Bio",
                    obscureText: false,
                  ),
                  Gap(50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: LongButton(
                          buttonColor: Color(0xFFF90909),
                          buttonText: "Reset Password",
                          onTap: passwordReset,
                        ),
                      ),
                      Expanded(
                        child: LongButton(
                          buttonText: "Update",
                          onTap: () {
                            String updatedBio = _bioController.text;
                            updateProfileData(updatedBio);
                          },
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
