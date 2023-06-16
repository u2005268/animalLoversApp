import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SidebarListtile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const SidebarListtile(
      {Key? key, required this.icon, required this.text, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.black,
      ),
      title: Text(text),
      onTap: onTap,
    );
  }
}
