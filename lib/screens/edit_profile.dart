import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:animal_lovers_app/widgets/underlineTextfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class EditProfilePage extends StatefulWidget {
  final String username;
  final String email;
  final String bio;
  final String? photoUrl;
  final Function(String bio, String? photoUrl) onProfileUpdated;

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
  File? _imageFile;
  late String? _currentPhotoUrl;

  void showErrorMessage(String message, bool isSuccess) {
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
                  isSuccess
                      ? Icons.check_circle_outline
                      : Icons.cancel_outlined,
                  size: 80.0,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                Gap(20.0),
                Text(
                  isSuccess ? 'Done' : 'Error',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
                Gap(20.0),
                Text(
                  isSuccess ? message : message,
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

  Future<void> passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text,
      );
      showErrorMessage("Password reset link sent! Check your email.", true);
    } on FirebaseAuthException catch (e) {
      showErrorMessage(e.message.toString(), false);
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _emailController = TextEditingController(text: widget.email);
    _bioController = TextEditingController(text: widget.bio);
    _changePasswordController = TextEditingController();
    _currentPhotoUrl = widget.photoUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    _changePasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Camera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromCamera();
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getImageFromGallery();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _getImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _imageFile = File(pickedImage.path);
      });
    }
  }

  void updateProfileData(String updatedBio, String? photoUrl) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        if (_imageFile != null) {
          // Upload new image and create/update 'photoUrl' field
          final storageRef =
              FirebaseStorage.instance.ref().child('users/$userId.jpg');
          final uploadTask = storageRef.putFile(_imageFile!);
          final snapshot = await uploadTask.whenComplete(() {});
          final downloadUrl = await snapshot.ref.getDownloadURL();
          photoUrl = downloadUrl;
          await userRef.set({
            'photoUrl': downloadUrl,
          }, SetOptions(merge: true));
        }

        // Update 'bio' field
        await userRef.update({
          'bio': updatedBio,
        });

        widget.onProfileUpdated(updatedBio, photoUrl);

        showStatusPopup(context, true);
      }
    } catch (error) {
      showStatusPopup(context, false);
    }
  }

  Future<void> _deleteImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Image'),
          content: Text('Are you sure you want to delete your profile image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("No", style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: _performDeleteImage,
              child: Text("Yes", style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performDeleteImage() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userId = currentUser.uid;
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        if (widget.photoUrl != null && widget.photoUrl!.isNotEmpty) {
          // Delete image from Firebase Storage
          final storageRef =
              FirebaseStorage.instance.refFromURL(widget.photoUrl!);
          await storageRef.delete();
          await userRef.update({'photoUrl': null});

          // Update the _currentPhotoUrl to null
          setState(() {
            _currentPhotoUrl = null;
          });

          // Update the photoUrl in the parent widget
          widget.onProfileUpdated(widget.bio, null);
        }

        setState(() {
          _imageFile = null;
        });
      }

      Navigator.of(context).pop(); // Close the dialog
    } catch (error) {
      showErrorMessage(
          'Failed to delete the profile image. Please try again.', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Edit Profile",
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.secondaryColor,
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
        decoration: Styles.gradientBackground(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Stack(
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
                          child: _imageFile != null
                              ? Image.file(_imageFile!)
                              : (_currentPhotoUrl != null &&
                                      _currentPhotoUrl!.isNotEmpty)
                                  ? Image.network(_currentPhotoUrl!)
                                  : Image.asset('images/user.png'),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 25,
                          height: 25,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Styles.secondaryColor,
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: FractionalTranslation(
                              translation: Offset(-0.2, -0.2),
                              child: Transform.translate(
                                offset: Offset(0.5, 0.5),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.camera_alt_rounded,
                                    size: 20,
                                  ),
                                  onPressed: _selectImage,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 12,
                        child: Visibility(
                          visible: _currentPhotoUrl != null &&
                              _currentPhotoUrl!.isNotEmpty,
                          child: GestureDetector(
                            onTap: _deleteImage,
                            child: Container(
                              width: 25,
                              height: 25,
                              child: Icon(
                                Icons.delete_outline_rounded,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(5),
                  Text(
                    widget.username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(5),
                  Text(
                    widget.email,
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
                          buttonColor: Styles.red,
                          buttonText: "Reset Password",
                          onTap: passwordReset,
                        ),
                      ),
                      Expanded(
                        child: LongButton(
                          buttonText: "Update",
                          onTap: () {
                            String updatedBio = _bioController.text;
                            updateProfileData(updatedBio, _currentPhotoUrl);
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
