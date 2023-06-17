import 'package:flutter/material.dart';

class ShortButton extends StatefulWidget {
  final Function()? onTap;
  final String buttonText;
  bool isTapped = false;
  ShortButton(
      {Key? key,
      required this.onTap,
      required this.buttonText,
      required this.isTapped})
      : super(key: key);

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
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        // margin: EdgeInsets.symmetric(horizontal: 165),
        decoration: BoxDecoration(
          color: widget.isTapped ? Color(0xFF1B4332) : Color(0xFFD2FFD2),
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
