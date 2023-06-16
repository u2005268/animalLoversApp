import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomizedTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obsureText;
  final Icon icon;

  const CustomizedTextField(
      {Key? key,
      required this.controller,
      required this.hintText,
      required this.obsureText,
      required this.icon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obsureText,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFD7FFD7)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: Color(0xFFD7FFD7),
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          prefixIcon: icon,
        ),
      ),
    );
  }
}
