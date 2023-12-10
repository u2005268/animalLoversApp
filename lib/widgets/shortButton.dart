import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/material.dart';

class ShortButton extends StatefulWidget {
  final Function()? onTap;
  final String buttonText;
  final double width;
  bool isTapped = false;

  ShortButton({
    Key? key,
    required this.onTap,
    required this.buttonText,
    required this.isTapped,
    required this.width,
  }) : super(key: key);

  @override
  _ShortButtonState createState() => _ShortButtonState();
}

class _ShortButtonState extends State<ShortButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget.isTapped == false) {
            widget.isTapped = !widget.isTapped;
          }
        });
        if (widget.onTap != null) {
          widget.onTap!();
        }
      },
      child: Container(
        width: widget.width, // Set the width here
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: widget.isTapped ? Styles.primaryColor : Styles.secondaryColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            widget.buttonText,
            style: TextStyle(
              color: widget.isTapped ? Colors.white : Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
