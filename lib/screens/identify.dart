import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/dashedBorder.dart';
import 'package:animal_lovers_app/widgets/longButton.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:tflite/tflite.dart';

class IdentifyPage extends StatefulWidget {
  const IdentifyPage({Key? key}) : super(key: key);

  @override
  State<IdentifyPage> createState() => _IdentifyPageState();
}

class _IdentifyPageState extends State<IdentifyPage> {
  File? _imageFile;
  String? imageUrl;
  late bool _loading;
  late List _outputs;

  @override
  void initState() {
    super.initState();
    _loading = true;
    _outputs = [];

    loadModel().then((val) {
      setState(() {
        _loading = false;
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
      model: "recognition_model/model_unquant.tflite",
      labels: "recognition_model/labels.txt",
      // useGpuDelegate: true,
    );
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
        _loading = true;
        _imageFile = File(pickedImage.path);
      });
      classifyImage(_imageFile);
    }
  }

  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _loading = true;
        _imageFile = File(pickedImage.path);
      });
      classifyImage(_imageFile);
    }
  }

  classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 2,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );

    setState(() {
      _loading = false;
      _outputs = output ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Identify",
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
            LongButton(
              buttonText: "Upload Photo",
              onTap: _selectImage,
            ),
            Gap(50),
            _outputs != null && _outputs.isNotEmpty
                ? Container(
                    width: double
                        .infinity, // Set the width to fill the available space
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "The image uploaded probably is ",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          "${_outputs[0]["label"]}"
                              .replaceAll(RegExp(r'[0-9]'), '')
                              .trim(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            color: Styles.primaryColor,
                          ),
                          maxLines: 1, // Set the maximum number of lines
                          overflow: TextOverflow
                              .ellipsis, // Set the overflow behavior
                        ),
                        Text(
                          ".",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    "",
                    textAlign: TextAlign.center,
                  )
          ],
        ),
      ),
    );
  }
}
