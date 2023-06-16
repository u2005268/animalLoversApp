import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderlineTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obsureText;
  const UnderlineTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obsureText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obsureText,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}
