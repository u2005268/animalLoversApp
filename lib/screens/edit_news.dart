import 'package:animal_lovers_app/screens/news.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/dashedBorder.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:animal_lovers_app/widgets/underlineTextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditNewsPage extends StatefulWidget {
  final String? title;
  final String? description;
  final String? imageUrl;
  final Timestamp? timestamp;
  final String? newsId;

  const EditNewsPage({
    Key? key,
    this.title,
    this.description,
    this.imageUrl,
    this.timestamp,
    this.newsId,
  }) : super(key: key);

  @override
  State<EditNewsPage> createState() => _EditNewsPageState();
}

class _EditNewsPageState extends State<EditNewsPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  File? _imageFile;
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    loadNewsData();
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

  void _handleSubmission() async {
    // Get values from the text fields
    String title = _titleController.text;
    String description = _descriptionController.text;

    // Create a reference to the Firestore collection
    CollectionReference news = FirebaseFirestore.instance.collection('news');

    try {
      // Upload a new news with an image
      if (_imageFile != null) {
        // Check if the image size is below 5MB
        if (await _imageFile!.length() > 5 * 1024 * 1024) {
          // Show a warning message if the image size exceeds 5MB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image size should not exceed 5MB."),
            ),
          );
          return;
        }

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('news_images/${DateTime.now()}.png');
        await storageReference.putFile(_imageFile!);
        String imageUrl = await storageReference.getDownloadURL();

        // Add a new document to the "news" collection with image URL
        await news.add({
          'title': title,
          'description': description,
          'imageUrl': imageUrl,
          'timestamp': DateTime.now(),
        });

        showStatusPopup(context, true);

        // Clear the text fields and image file after a successful submission
        _resetForm();

        // Show success popup with a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewsPage()),
          );
        });
      } else {
        showStatusPopup(context, false);
      }
    } catch (e) {
      showStatusPopup(context, false);
    }
  }

  // Method to reset the form to its initial state
  void _resetForm() {
    setState(() {
      _titleController.clear();
      _descriptionController.clear();
      _imageFile = null;
    });
  }

  void _handleUpdate() async {
    String title = _titleController.text;
    String description = _descriptionController.text;

    // Create a reference to the Firestore collection
    CollectionReference news = FirebaseFirestore.instance.collection('news');

    try {
      if (widget.newsId != null) {
        // Retrieve the previous image URL
        final newsDoc = await FirebaseFirestore.instance
            .collection('news')
            .doc(widget.newsId)
            .get();
        if (newsDoc.exists) {
          final previousImageUrl = newsDoc.data()?['imageUrl'];

          // Check if a new image has been selected
          if (_imageFile != null) {
            // Check if the image size is below 5MB
            if (await _imageFile!.length() > 5 * 1024 * 1024) {
              // Show a warning message if the image size exceeds 5MB
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Image size should not exceed 5MB."),
                ),
              );
              return;
            }

            // Upload the new image to Firebase Storage
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('newsImages/${DateTime.now()}.png');
            await storageReference.putFile(_imageFile!);
            String imageUrl = await storageReference.getDownloadURL();

            // Update an existing news based on newsId
            await news.doc(widget.newsId).update({
              'title': title,
              'description': description,
              'imageUrl': imageUrl,
              'timestamp': DateTime.now(),
            });

            // Delete the previous image from Firebase Storage
            if (previousImageUrl != null) {
              final storageRef =
                  FirebaseStorage.instance.refFromURL(previousImageUrl);
              await storageRef.delete();
            }
          } else {
            // Update an existing news without changing the image
            await news.doc(widget.newsId).update({
              'title': title,
              'description': description,
              'timestamp': DateTime.now(),
            });
          }

          showStatusPopup(context, true);
          // Show success popup with a delay
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => NewsPage()),
            );
          });
        }
      }
    } catch (e) {
      print('Error updating news: $e');
      showStatusPopup(context, false);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Are you sure you want to delete this news?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                "No",
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                // Perform the delete operation
                _deleteNews();
                Navigator.of(context).pop();
              },
              child: Text(
                "Yes",
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );
  }

  void _deleteNews() async {
    try {
      // Get a reference to the Firestore collection
      CollectionReference news = FirebaseFirestore.instance.collection('news');

      // Retrieve the news document
      final newsDoc = await news.doc(widget.newsId).get();

      if (newsDoc.exists) {
        // Get the imageUrl from the news document
        final imageUrl = (newsDoc.data() as Map<String, dynamic>)['imageUrl'];

        // Delete the news document
        await news.doc(widget.newsId).delete();

        // Delete the associated image from Firebase Storage if it exists
        if (imageUrl != null) {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        }

        // Show a success message
        showStatusPopup(context, true);

        // Navigate to a different page after a delay
        Future.delayed(Duration(seconds: 3), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewsPage()),
          );
        });
      }
    } catch (error) {
      print('Error deleting news: $error');
      showStatusPopup(context, false);
    }
  }

  //load news data based on newsId
  Future<void> loadNewsData() async {
    try {
      if (widget.newsId != null) {
        final newsDoc = await FirebaseFirestore.instance
            .collection('news')
            .doc(widget.newsId)
            .get();

        if (newsDoc.exists) {
          final data = newsDoc.data() as Map<String, dynamic>;
          setState(() {
            _titleController.text = data['title'];
            _descriptionController.text = data['description'];
            imageUrl = data['imageUrl'];
          });
        }
      }
    } catch (e) {
      // Handle any errors while fetching data
      print('Error loading news data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "News",
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
          child: SingleChildScrollView(
            child: Form(
              autovalidateMode:
                  AutovalidateMode.always, // Automatically validate the form
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  UnderlineTextfield(
                    controller: _titleController,
                    hintText: "Title",
                    obscureText: false,
                    validator: (value) {
                      // Add validation for this text field
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be empty!';
                      }
                      return null;
                    },
                  ),

                  UnderlineTextfield(
                    controller: _descriptionController,
                    hintText: "Description",
                    obscureText: false,
                    validator: (value) {
                      // Add validation for this text field
                      if (value == null || value.isEmpty) {
                        return 'This field cannot be empty!';
                      }
                      return null;
                    },
                  ),
                  Gap(10),
                  // Image upload frame with dashed border
                  GestureDetector(
                    onTap: _selectImage,
                    child: Container(
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.upload_file,
                                      size: 20,
                                      color: Colors.grey,
                                    ),
                                    Gap(5),
                                    Text(
                                      "Upload Photo (Required)",
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
                  ),

                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Attach photo. Size of the file should not exceed 5MB.",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Gap(10),

                  widget.newsId != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: LongButton(
                                buttonColor: Styles.red,
                                buttonText: "Delete",
                                onTap: _showDeleteConfirmationDialog,
                              ),
                            ),
                            Expanded(
                              child: LongButton(
                                buttonText: "Update",
                                onTap: _handleUpdate,
                              ),
                            ),
                          ],
                        )
                      : LongButton(
                          buttonText: "Submit",
                          onTap: _handleSubmission,
                        ),

                  Gap(30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
