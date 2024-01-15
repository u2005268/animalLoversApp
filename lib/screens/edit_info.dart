import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:animal_lovers_app/widgets/underlineTextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditInfoPage extends StatefulWidget {
  final String? title;
  final String? url;
  final String? infoId;

  const EditInfoPage({
    Key? key,
    this.title,
    this.url,
    this.infoId,
  }) : super(key: key);

  @override
  State<EditInfoPage> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _linkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadInfoData();
  }

  //load info data based on infoId
  Future<void> loadInfoData() async {
    try {
      if (widget.infoId != null) {
        final infoDoc = await FirebaseFirestore.instance
            .collection('info')
            .doc(widget.infoId)
            .get();

        if (infoDoc.exists) {
          final data = infoDoc.data() as Map<String, dynamic>;
          setState(() {
            _titleController.text = data['title'];
            _linkController.text = data['url'];
          });
        }
      }
    } catch (e) {
      // Handle any errors while fetching data
      print('Error loading info data: $e');
    }
  }

  void _handleSubmission() async {
    // Get values from the text fields
    String title = _titleController.text;
    String link = _linkController.text;

    // Create a reference to the Firestore collection
    CollectionReference informations =
        FirebaseFirestore.instance.collection('info');

    try {
      // Add a new document to the "informations" collection with image URL
      await informations.add({
        'title': title,
        'url': link,
      });

      showStatusPopup(context, true);

      // Clear the text fields and image file after a successful submission
      _resetForm();

      // Show success popup with a delay
      Future.delayed(Duration(seconds: 1), () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => InfoPage()),
        );
      });
    } catch (e) {
      showStatusPopup(context, false);
    }
  }

  // Method to reset the form to its initial state
  void _resetForm() {
    setState(() {
      _titleController.clear();
      _linkController.clear();
    });
  }

  void _handleUpdate() async {
    String title = _titleController.text;
    String link = _linkController.text;

    // Create a reference to the Firestore collection
    CollectionReference informations =
        FirebaseFirestore.instance.collection('info');

    try {
      if (widget.infoId != null) {
        // Retrieve the previous image URL
        final infoDoc = await FirebaseFirestore.instance
            .collection('info')
            .doc(widget.infoId)
            .get();
        if (infoDoc.exists) {
          // Update an existing info based on infoId
          await informations.doc(widget.infoId).update({
            'title': title,
            'url': link,
          });
        }
        showStatusPopup(context, true);

        // Show success popup with a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfoPage()),
          );
        });
      }
    } catch (e) {
      print('Error updating information: $e');
      showStatusPopup(context, false);
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete"),
          content: Text("Are you sure you want to delete this info?"),
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
                _deleteInformation();
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

  void _deleteInformation() async {
    try {
      // Get a reference to the Firestore collection
      CollectionReference informations =
          FirebaseFirestore.instance.collection('info');

      // Retrieve the information document
      final informationDoc = await informations.doc(widget.infoId).get();

      if (informationDoc.exists) {
        // Delete the information document
        await informations.doc(widget.infoId).delete();

        // Show a success message
        showStatusPopup(context, true);

        // Navigate to a different page after a delay
        Future.delayed(Duration(seconds: 3), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => InfoPage()),
          );
        });
      }
    } catch (error) {
      print('Error deleting information: $error');
      showStatusPopup(context, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Information",
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                  Gap(10),
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
                  widget.infoId != null
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
