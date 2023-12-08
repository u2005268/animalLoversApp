import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final Widget? leading; // Make the leading widget optional
  final List<Widget>? actionWidgets; // Making this optional

  CustomAppBar(
      {Key? key, required this.titleText, this.leading, this.actionWidgets})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 0,
      title: Text(
        titleText,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: Offset(0, 1),
              blurRadius: 4,
            ),
          ],
        ),
      ),
      leading: leading, // Set the leading widget
      actions: actionWidgets ??
          [], // Use the actions if provided, otherwise an empty list
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
