import 'package:animal_lovers_app/components/longButton.dart';
import 'package:animal_lovers_app/components/underlineTextfield.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //text editing controllers
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _bioController = TextEditingController();
  final _changePasswordController = TextEditingController();
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
              onPressed: () => Navigator.pop(
                  context), // Navigate back to the previous page,),
            ),
          ),
        ),
      ),
      body: Container(
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
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Stack(children: [
                    SizedBox(
                      width: 90,
                      height: 90,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          'images/user.png',
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
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
                  ]),
                  Gap(20),
                  UnderlineTextField(
                    controller: _usernameController,
                    hintText: "Username",
                    obsureText: false,
                  ),
                  UnderlineTextField(
                    controller: _emailController,
                    hintText: "Email",
                    obsureText: false,
                  ),
                  UnderlineTextField(
                    controller: _bioController,
                    hintText: "Bio",
                    obsureText: false,
                  ),
                  UnderlineTextField(
                    controller: _changePasswordController,
                    hintText: "Change Password",
                    obsureText: true,
                  ),
                  Gap(20),
                  LongButton(
                    buttonText: "update",
                    onTap: () {},
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
