import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/observation_history.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/dashedBorder.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/showStatusPopUp.dart';
import 'package:animal_lovers_app/widgets/underlineTextfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:intl/intl.dart';

class ObservationPage extends StatefulWidget {
  final String? observationId;
  const ObservationPage({Key? key, this.observationId}) : super(key: key);

  @override
  State<ObservationPage> createState() => _ObservationPageState();
}

class _ObservationPageState extends State<ObservationPage> {
  bool _isChecked = false;
  File? _imageFile;
  TextEditingController _whatDidYouSeeController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  TextEditingController _additionalInformationController =
      TextEditingController();
  late DateTime selectedDate = DateTime.now();
  String? imageUrl;
  late double latitude;
  late double longitude;
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    getCurrentDateTime(); // Set initial date and time
    _getCurrentLocation();
    loadObservationData();
  }

// Function to get the current date and time
  void getCurrentDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('dd-MM-yyyy'); // Format for date
    final timeFormatter = DateFormat('HH:mm:ss'); // Format for time

    final formattedDate = formatter.format(now);
    final formattedTime = timeFormatter.format(now);

    _dateController.text = formattedDate;
    _timeController.text = formattedTime;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      final formatter = DateFormat('dd-MM-yyyy'); // Format for date
      setState(() {
        selectedDate = picked;
        _dateController.text = formatter.format(picked);
      });
    }
  }

  // Function to get the user's current location
  Future<void> _getCurrentLocation() async {
    Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (position != null) {
      // Get the latitude and longitude
      latitude = position.latitude;
      longitude = position.longitude;

      // Reverse geocode the coordinates to get the address
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];

        // Build a complete address string
        String address = '';

        // Concatenate components using null-aware operators
        address += placemark.subThoroughfare ?? '';
        address +=
            (address.isNotEmpty ? ' ' : '') + (placemark.thoroughfare ?? '');
        address +=
            (address.isNotEmpty ? ', ' : '') + (placemark.subLocality ?? '');
        address +=
            (address.isNotEmpty ? ', ' : '') + (placemark.locality ?? '');
        address += (address.isNotEmpty ? ', ' : '') +
            (placemark.administrativeArea ?? '');
        address += (address.isNotEmpty ? ', ' : '') + (placemark.country ?? '');

        // Display the complete address in the text field
        _locationController.text = address;
      }
    }
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

  //load observation data based on observationId
  Future<void> loadObservationData() async {
    try {
      if (widget.observationId != null) {
        final observationDoc = await FirebaseFirestore.instance
            .collection('observations')
            .doc(widget.observationId)
            .get();

        if (observationDoc.exists) {
          final data = observationDoc.data() as Map<String, dynamic>;
          setState(() {
            _whatDidYouSeeController.text = data['whatDidYouSee'];
            _locationController.text = data['location'];
            _dateController.text = data['date'];
            _timeController.text = data['time'];
            _additionalInformationController.text =
                data['additionalInformation'] ?? "";
            imageUrl = data['imageUrl'];
          });
        }
      }
    } catch (e) {
      // Handle any errors while fetching data
      print('Error loading observation data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Observation",
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
                      controller: _whatDidYouSeeController,
                      hintText: "What did you see",
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
                      controller: _locationController,
                      hintText: "Location",
                      obscureText: false,
                      validator: (value) {
                        // Add validation for this text field
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty!';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(Icons.location_on_outlined),
                        onPressed: () {
                          _getCurrentLocation(); // Update location when tapped
                        },
                      ),
                    ),
                    UnderlineTextfield(
                      controller: _dateController,
                      hintText: "Date",
                      obscureText: false,
                      validator: (value) {
                        // Add validation for this text field
                        if (value == null || value.isEmpty) {
                          return 'This field cannot be empty!';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(Icons.calendar_month_outlined), // Map icon
                        onPressed: () {
                          _selectDate(context); // Update location when tapped
                        },
                      ),
                    ),
                    UnderlineTextfield(
                      controller: _timeController,
                      hintText: "Time",
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
                      controller: _additionalInformationController,
                      hintText: "Additional Information (Optional)",
                      obscureText: false,
                    ),
                    Gap(15),
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
                                        "Upload Photo",
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
                            "Attach photo. Size of the file should not exceed 1MB.",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _isChecked = newValue ?? false;
                              });
                            },
                          ),
                          Text(
                            "I agree with all the data provided.",
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                    Gap(10),
                    widget.observationId != null
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: LongButton(
                                  buttonColor: Styles.red,
                                  buttonText: "Delete",
                                  onTap: _handleDelete,
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

  void _handleUpdate() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    // Get values from the text fields
    String whatDidYouSee = _whatDidYouSeeController.text;
    String location = _locationController.text;
    String date = _dateController.text;
    String time = _timeController.text;
    String additionalInformation = _additionalInformationController.text;

    // Create a reference to the Firestore collection
    CollectionReference observations =
        FirebaseFirestore.instance.collection('observations');

    if (!_isChecked) {
      // Show a warning message if the checkbox is not checked
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Please agree with the data provided before submitting."),
        ),
      );
      return;
    }

    try {
      if (widget.observationId != null) {
        // Retrieve the previous image URL
        final observationDoc = await FirebaseFirestore.instance
            .collection('observations')
            .doc(widget.observationId)
            .get();
        if (observationDoc.exists) {
          final previousImageUrl = observationDoc.data()?['imageUrl'];

          // Update an existing observation based on observationId
          await observations.doc(widget.observationId).update({
            'whatDidYouSee': whatDidYouSee,
            'location': location,
            'date': date,
            'time': time,
            'additionalInformation': additionalInformation,
            'latitude': latitude,
            'longitude': longitude,
          });

          // Check if a new image has been selected
          if (_imageFile != null) {
            // Upload the new image to Firebase Storage
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('observation_images/${DateTime.now()}.png');
            await storageReference.putFile(_imageFile!);
            String imageUrl = await storageReference.getDownloadURL();

            // Update the observation document with the new image URL
            await observations.doc(widget.observationId).update({
              'imageUrl': imageUrl,
            });

            // Delete the previous image from Firebase Storage
            if (previousImageUrl != null) {
              final storageRef =
                  FirebaseStorage.instance.refFromURL(previousImageUrl);
              await storageRef.delete();
            }
          }
        }
        showStatusPopup(context, true);
        // Show success popup with a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ObservationHistoryPage()),
          );
        });
      }
    } catch (e) {
      showStatusPopup(context, false);
    }
  }

  void _handleDelete() async {
    try {
      if (widget.observationId != null) {
        // Show a confirmation dialog
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text("Delete"),
              content:
                  Text("Are you sure you want to delete this observation?"),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text(
                    "No",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                MaterialButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close the dialog

                    // Get a reference to the Firestore collection
                    CollectionReference observations =
                        FirebaseFirestore.instance.collection('observations');

                    // Retrieve the observation document
                    final observationDoc =
                        await observations.doc(widget.observationId).get();

                    if (observationDoc.exists) {
                      // Get the imageUrl from the observation document
                      final imageUrl = (observationDoc.data()
                          as Map<String, dynamic>)['imageUrl'];

                      // Delete the observation document
                      await observations.doc(widget.observationId).delete();

                      // Delete the associated image from Firebase Storage if it exists
                      if (imageUrl != null) {
                        final storageRef =
                            FirebaseStorage.instance.refFromURL(imageUrl);
                        await storageRef.delete();
                      }

                      // Show a success message
                      showStatusPopup(context, true);

                      // Navigate to a different page after a delay
                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ObservationHistoryPage()),
                        );
                      });
                    }
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
    } catch (e) {
      // Handle any errors that occur during deletion
      showStatusPopup(context, false);
      print('Error deleting observation: $e');
    }
  }

  void _handleSubmission() async {
    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    // Get values from the text fields
    String userId = user.uid;
    String whatDidYouSee = _whatDidYouSeeController.text;
    String location = _locationController.text;
    String date = _dateController.text;
    String time = _timeController.text;
    String additionalInformation = _additionalInformationController.text;

    // Create a reference to the Firestore collection
    CollectionReference observations =
        FirebaseFirestore.instance.collection('observations');

    if (!_isChecked) {
      // Show a warning message if the checkbox is not checked
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text("Please agree with the data provided before submitting."),
        ),
      );
      return;
    }

    try {
      // Upload a new observation with an image
      if (_imageFile != null) {
        Reference storageReference = FirebaseStorage.instance
            .ref()
            .child('observation_images/${DateTime.now()}.png');
        await storageReference.putFile(_imageFile!);
        String imageUrl = await storageReference.getDownloadURL();

        // Add a new document to the "observations" collection with image URL
        await observations.add({
          'userId': userId,
          'whatDidYouSee': whatDidYouSee,
          'location': location,
          'date': date,
          'time': time,
          'additionalInformation': additionalInformation,
          'imageUrl': imageUrl,
          'latitude': latitude,
          'longitude': longitude,
        });

        showStatusPopup(context, true);

        // Clear the text fields and image file after a successful submission
        _resetForm();

        // Show success popup with a delay
        Future.delayed(Duration(seconds: 1), () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AnimalTracker()),
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
      _whatDidYouSeeController.clear();
      _locationController.clear();
      _additionalInformationController.clear();
      _imageFile = null;
      getCurrentDateTime(); // Update date and time to current values
    });
  }
}
