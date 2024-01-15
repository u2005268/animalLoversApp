import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/material.dart';

class DashedBorder extends StatelessWidget {
  final Widget child;

  const DashedBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DashedBorderPainter(),
      child: child,
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Styles.primaryColor // Border color
      ..strokeWidth = 2 // Border width
      ..style = PaintingStyle.stroke;

    final double dashWidth = 5; // Width of each dash
    final double dashSpace = 5; // Space between dashes

    // Top border
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Bottom border
    startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX + dashWidth, size.height),
        paint,
      );
      startX += dashWidth + dashSpace;
    }

    // Left border
    double startLeftY = 0;
    while (startLeftY < size.height) {
      canvas.drawLine(
        Offset(0, startLeftY),
        Offset(0, startLeftY + dashWidth),
        paint,
      );
      startLeftY += dashWidth + dashSpace;
    }

    // Right border
    double startRightY = size.height;
    while (startRightY > 0) {
      canvas.drawLine(
        Offset(size.width, startRightY),
        Offset(size.width, startRightY - dashWidth),
        paint,
      );
      startRightY -= dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
