import 'package:animal_lovers_app/screens/donate.dart';
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

class EditDonatePage extends StatefulWidget {
  final String? imageUrl;
  final String? title;
  final String? logoImageUrl;
  final String? name;
  final String? url;
  final String? donationId;

  const EditDonatePage({
    Key? key,
    this.imageUrl,
    this.title,
    this.logoImageUrl,
    this.name,
    this.url,
    this.donationId,
  }) : super(key: key);

  @override
  State<EditDonatePage> createState() => _EditDonatePageState();
}

class _EditDonatePageState extends State<EditDonatePage> {
  TextEditingController _nameController = TextEditingController();
  File? _logoImageFile;
  String? logoImageUrl;
  TextEditingController _titleController = TextEditingController();
  File? _imageFile;
  String? imageUrl;
  TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadDonationData();
  }

  Future<void> _getLogoImageFromCamera() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      setState(() {
        _logoImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _getLogoImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _logoImageFile = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectLogoImage() async {
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
                    _getLogoImageFromCamera();
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                ),
                GestureDetector(
                  child: Text('Gallery'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _getLogoImageFromGallery();
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
    String name = _nameController.text;
    String title = _titleController.text;
    String link = _linkController.text;

    // Create a reference to the Firestore collection
    CollectionReference donations =
        FirebaseFirestore.instance.collection('donation');

    try {
      // Upload a new donation with an image
      if (_imageFile != null && _logoImageFile != null) {
        // Check if the image sizes are below 5MB
        if (await _imageFile!.length() > 5 * 1024 * 1024 ||
            await _logoImageFile!.length() > 5 * 1024 * 1024) {
          // Show a warning message if any image size exceeds 5MB
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Image sizes should not exceed 5MB."),
            ),
          );
          return;
        }

        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('donate_images/${DateTime.now()}.png');
        await storageReference.putFile(_imageFile!);
        String imageUrl = await storageReference.getDownloadURL();

        Reference storageReference1 = FirebaseStorage.instance
            .ref()
            .child('donate_logo_images/${DateTime.now()}.png');
        await storageReference1.putFile(_logoImageFile!);
        String logoImageUrl = await storageReference1.getDownloadURL();

        // Add a new document to the "donations" collection with image URL
        await donations.add({
          'title': title,
          'name': name,
          'url': link,
          'image': imageUrl,
          'logoImage': logoImageUrl,
        });

        showStatusPopup(context, true);

        // Clear the text fields and image files after a successful submission
        _resetForm();

        // Show success popup with a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DonatePage()),
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
      _nameController.clear();
      _titleController.clear();
      _linkController.clear();
      _imageFile = null;
      _logoImageFile = null;
    });
  }

  //load donation data based on donationId
  Future<void> loadDonationData() async {
    try {
      if (widget.donationId != null) {
        final donationDoc = await FirebaseFirestore.instance
            .collection('donation')
            .doc(widget.donationId)
            .get();

        if (donationDoc.exists) {
          final data = donationDoc.data() as Map<String, dynamic>;
          setState(() {
            _nameController.text = data['name'];
            logoImageUrl = data['logoImage'];
            _titleController.text = data['title'];
            imageUrl = data['image'];
            _linkController.text = data['url'];
          });
        }
      }
    } catch (e) {
      // Handle any errors while fetching data
      print('Error loading donation data: $e');
    }
  }

  void _handleUpdate() async {
    String name = _nameController.text;
    String title = _titleController.text;
    String link = _linkController.text;

    // Create a reference to the Firestore collection
    CollectionReference donations =
        FirebaseFirestore.instance.collection('donation');

    try {
      if (widget.donationId != null) {
        // Retrieve the previous image URL
        final donationDoc = await FirebaseFirestore.instance
            .collection('donation')
            .doc(widget.donationId)
            .get();
        if (donationDoc.exists) {
          final previousLogoImageUrl = donationDoc.data()?['logoImage'];
          final previousImageUrl = donationDoc.data()?['image'];

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
                .child('donate_images/${DateTime.now()}.png');
            await storageReference.putFile(_imageFile!);
            String imageUrl = await storageReference.getDownloadURL();

            // Update the donation document with the new image URL
            await donations.doc(widget.donationId).update({
              'image': imageUrl,
            });

            // Delete the previous image from Firebase Storage
            if (previousImageUrl != null) {
              final storageRef =
                  FirebaseStorage.instance.refFromURL(previousImageUrl);
              await storageRef.delete();
            }
          }

          // Check if a new logo image has been selected
          if (_logoImageFile != null) {
            // Check if the logo image size is below 5MB
            if (await _logoImageFile!.length() > 5 * 1024 * 1024) {
              // Show a warning message if the logo image size exceeds 5MB
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Logo image size should not exceed 5MB."),
                ),
              );
              return;
            }

            // Upload the new logo image to Firebase Storage
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('donate_logo_images/${DateTime.now()}.png');
            await storageReference.putFile(_logoImageFile!);
            String logoImageUrl = await storageReference.getDownloadURL();

            // Update the donation document with the new logo image URL
            await donations.doc(widget.donationId).update({
              'logoImage': logoImageUrl,
            });

            // Delete the previous logo image from Firebase Storage
            if (previousLogoImageUrl != null) {
              final storageRef =
                  FirebaseStorage.instance.refFromURL(previousLogoImageUrl);
              await storageRef.delete();
            }
          }

          // Update an existing donation based on donationId
          await donations.doc(widget.donationId).update({
            'title': title,
            'name': name,
            'url': link,
          });

          showStatusPopup(context, true);
          // Show success popup with a delay
          Future.delayed(Duration(seconds: 1), () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DonatePage()),
            );
          });
        }
      }
    } catch (e) {
      print('Error updating donation: $e');
      showStatusPopup(context, false);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Are you sure you want to delete this donation?"),
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
                _deleteDonation();
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

  void _deleteDonation() async {
    try {
      // Get a reference to the Firestore collection
      CollectionReference donations =
          FirebaseFirestore.instance.collection('donation');

      // Retrieve the donation document
      final donationDoc = await donations.doc(widget.donationId).get();

      if (donationDoc.exists) {
        // Get the imageUrl from the donation document
        final imageUrl = (donationDoc.data() as Map<String, dynamic>)['image'];

        // Delete the donation document
        await donations.doc(widget.donationId).delete();

        // Delete the associated image from Firebase Storage if it exists
        if (imageUrl != null) {
          final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
          await storageRef.delete();
        }

        final logoImageUrl =
            (donationDoc.data() as Map<String, dynamic>)['logoImage'];

        // Delete the donation document
        await donations.doc(widget.donationId).delete();

        // Delete the associated image from Firebase Storage if it exists
        if (logoImageUrl != null) {
          final storageRef = FirebaseStorage.instance.refFromURL(logoImageUrl);
          await storageRef.delete();
        }

        // Show a success message
        showStatusPopup(context, true);

        // Navigate to a different page after a delay
        Future.delayed(Duration(seconds: 3), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DonatePage()),
          );
        });
      }
    } catch (error) {
      print('Error deleting donation: $error');
      showStatusPopup(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Donation",
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
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                autovalidateMode:
                    AutovalidateMode.always, // Automatically validate the form
                child: Column(
                  children: [
                    // What did you see
                    UnderlineTextfield(
                      controller: _nameController,
                      hintText: "Organisation Name",
                      obscureText: false,
                      validator: (value) {
                        // Add validation for this text field
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty!';
                        }
                        return null;
                      },
                    ),

                    GestureDetector(
                      onTap: _selectLogoImage,
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
                                if (_logoImageFile != null)
                                  Expanded(
                                    child: Image.file(
                                      File(_logoImageFile!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                else if (logoImageUrl !=
                                    null) // Check if you have an imageUrl
                                  Expanded(
                                    child: Image.network(
                                      logoImageUrl!, // Use the imageUrl
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
                                        "Upload Logo Image",
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
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 25),
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
                      padding:
                          EdgeInsets.symmetric(vertical: 0, horizontal: 25),
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

                    UnderlineTextfield(
                      controller: _linkController,
                      hintText: "Link",
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
                    widget.donationId != null
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
      ),
    );
  }
}
