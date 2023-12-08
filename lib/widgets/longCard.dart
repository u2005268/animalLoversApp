import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class LongCard extends StatelessWidget {
  final String? text1;
  final String? text2;
  final String? text3;
  final String? imageUrl;
  final String? url;
  final VoidCallback? onEditPressed;

  const LongCard({
    Key? key,
    this.text1,
    this.text2,
    this.text3,
    this.imageUrl,
    this.url,
    this.onEditPressed,
  }) : super(key: key);

// Helper function to capitalize the first letter of each word
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    final words = text.split(' ');
    final capitalizedWords =
        words.map((word) => word[0].toUpperCase() + word.substring(1)).toList();
    return capitalizedWords.join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final commonCardStyle = BoxDecoration(
      color: Styles.lightGrey,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 2,
          offset: Offset(0, 1),
        ),
      ],
    );

    if (url != null && text1 != null) {
      // Build the first configuration with URL and text1
      return GestureDetector(
        onTap: () {
          if (url != null) {
            _launchURL(url!);
          }
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 80,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            margin: EdgeInsets.symmetric(horizontal: 25),
            decoration: commonCardStyle,
            child: Text(
              text1!,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    } else if (text1 != null &&
        text2 != null &&
        text3 != null &&
        imageUrl != null) {
      // Build the second configuration with text1, text2, text3, and imageUrl
      return GestureDetector(
        onTap: () {
          // Handle onTap for the second configuration if needed
        },
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 75,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: commonCardStyle,
            child: Row(
              children: [
                Image.network(
                  imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalizeWords(text1!),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 16), // Icon before text2
                          Gap(5),
                          Text(
                            text2!.split(',').first.trim(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 16),
                          Gap(5),
                          Text(
                            text3!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: onEditPressed,
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // Empty content
    }
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
