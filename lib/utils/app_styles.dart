import 'package:flutter/material.dart';

class Styles {
  static const Color primaryColor = Color(0xFF1B4332);
  static Color secondaryColor = Color(0xFFD7FFD7);
  static Color red = Color(0xFFF90909);
  static Color lightGrey = Color(0xFFE5EAEC);

  static BoxDecoration gradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.3646, 0.9062, 1.0],
        colors: [
          Colors.white,
          Colors.white,
          secondaryColor,
        ],
      ),
    );
  }
}
