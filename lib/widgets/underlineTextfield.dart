import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnderlineTextfield extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator; // Validator function
  final IconButton? suffixIcon;
  const UnderlineTextfield({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator, // Validator function parameter
    this.suffixIcon, // Optional suffix icon button
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          suffixIcon: suffixIcon, // Set the optional suffix icon
        ),
        validator: validator, // Assign the validator function
      ),
    );
  }
}
