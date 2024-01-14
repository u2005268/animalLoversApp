import 'package:animal_lovers_app/screens/feeds_history.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/dashedBorder.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PostFeedPage extends StatefulWidget {
  final String? postId;
  final String? initialDescription;
  final String? initialImageUrl;

  const PostFeedPage({
    Key? key,
    this.postId,
    this.initialDescription,
    this.initialImageUrl,
  }) : super(key: key);

  @override
  State<PostFeedPage> createState() => _PostFeedPageState();
}

class _PostFeedPageState extends State<PostFeedPage> {
  String? username;
  String? bio;
  String? photoUrl;
  final currentUser = FirebaseAuth.instance.currentUser!;
  File? _imageFile;
  String? imageUrl;
  TextEditingController _description = TextEditingController();
  int likeCount = 0;
  int commentCount = 0;
  final DateTime currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetchUserData();
    if (widget.initialDescription != null) {
      _description.text = widget.initialDescription!;
    }
    if (widget.initialImageUrl != null) {
      imageUrl = widget.initialImageUrl!;
    }
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

  void _handleSubmission() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    final Timestamp timestamp = Timestamp.fromDate(currentTime);

    if (user == null) {
      return;
    }

    // Get values from the text fields
    String userId = user.uid;
    String description = _description.text;

    // Create a reference to the Firestore collection
    CollectionReference feeds = FirebaseFirestore.instance.collection('feed');

    try {
      if (widget.postId == null) {
        // Upload a new feed with an image
        if (_imageFile != null) {
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('feed_images/${DateTime.now()}.png');
          await storageReference.putFile(_imageFile!);
          String imageUrl = await storageReference.getDownloadURL();

          // Add a new document to the "feeds" collection with image URL
          await feeds.add({
            'userId': userId,
            'description': description,
            'imageUrl': imageUrl,
            'likes': [],
            'comments': [],
            'timestamp': timestamp,
          });
        } else {
          showStatusPopup(context, false);
          return;
        }
      } else {
        // Get the URL of the old image
        String? oldImageUrl = widget.initialImageUrl;

        // Delete the old image if it exists
        if (oldImageUrl != null) {
          await FirebaseStorage.instance.refFromURL(oldImageUrl).delete();
        }

        // Upload the new image
        if (_imageFile != null) {
          Reference storageReference = FirebaseStorage.instance
              .ref()
              .child('feed_images/${DateTime.now()}.png');
          await storageReference.putFile(_imageFile!);
          String imageUrl = await storageReference.getDownloadURL();

          // Update an existing feed with the new image URL
          Map<String, dynamic> updateData = {
            'description': description,
            'imageUrl': imageUrl,
            'timestamp': timestamp,
          };
          await feeds.doc(widget.postId).update(updateData);
        } else {
          // Update an existing feed without changing the image
          Map<String, dynamic> updateData = {
            'description': description,
            'timestamp': timestamp,
          };
          await feeds.doc(widget.postId).update(updateData);
        }
      }

      showStatusPopup(context, true);

      // Clear the text fields and image file after a successful submission
      _resetForm();

      // Show success popup with a delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FeedsHistoryPage(),
          ),
        );
      });
    } catch (e) {
      showStatusPopup(context, false);
    }
  }

  // Method to reset the form to its initial state
  void _resetForm() {
    setState(() {
      _description.clear();
      _imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
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
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 5),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
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
                          Gap(8),
                          Text(
                            username ?? '',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    Gap(10),
                    Container(
                      height:
                          500, // Set the desired height for the Container here
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Styles.secondaryColor, // Shadow color
                            blurRadius: 1.0, // Spread radius
                            offset: Offset(0, 2), // Shadow position
                          ),
                        ],
                        border: Border.all(
                          width: 2.0, // Set the desired border width here
                          color: Colors.black, // Set the border color
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(
                            8.0)), // Optional: Add rounded corners
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextFormField(
                              maxLines:
                                  10, // Set to null for an unlimited number of lines
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                hintText: 'Enter your text here...',
                                border: InputBorder
                                    .none, // Remove the TextField's border
                              ),
                              controller: _description,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'This field cannot be empty!';
                                }
                                return null; // Return null if the input is valid
                              },
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width - 20,
                            height: 250,
                            padding: EdgeInsets.all(16),
                            child: CustomPaint(
                              painter: DashedBorderPainter(),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Display the selected image or upload button
                                    if (_imageFile != null)
                                      Expanded(
                                        child: Image.file(
                                          File(_imageFile!.path),
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else if (imageUrl !=
                                        null) // Check if you have an imageUrl
                                      Expanded(
                                        child: Image.network(
                                          imageUrl!, // Use the imageUrl
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    else
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.upload_file,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                          Gap(5),
                                          Text(
                                            "Please upload your photo",
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: IconButton(
                              icon: Icon(
                                Icons.camera_alt_rounded,
                                size: 20,
                              ),
                              onPressed: _selectImage,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(0),
                            child: LongButton(
                              buttonText: "  Post  ",
                              onTap: _handleSubmission,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
