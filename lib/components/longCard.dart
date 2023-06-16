import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LongCard extends StatelessWidget {
  final String url;
  final String buttonText;

  const LongCard({Key? key, required this.url, required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launchURL(url),
      child: MediaQuery(
        data: MediaQueryData(),
        child: SizedBox(
          width: MediaQuery.of(context)
              .size
              .width, // Set the width to the screen width
          height: 80,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: Color(0xFFE5EAEC),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Shadow color
                  spreadRadius: 1, // Spread radius
                  blurRadius: 2, // Blur radius
                  offset: Offset(0, 1), // Offset in the x and y direction
                ),
              ],
            ),
            child: Text(
              buttonText,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
