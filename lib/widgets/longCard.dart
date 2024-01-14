import 'dart:async';

import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

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

  @override
  Widget build(BuildContext context) {
    final commonCardStyle = BoxDecoration(
      color: Styles.lightGrey, // Replace with your desired color
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
            _openWebView(context, url!); // Open web view on tap
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
              style: TextStyle(
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
                        text1!,
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

  void _openWebView(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url),
      ),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Information",
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Styles.secondaryColor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.chevron_left_sharp,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          WebView(
            initialUrl: widget.url,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onPageFinished: (String url) {
              setState(() {
                _isLoading =
                    false; // Set loading state to false when page is loaded
              });
            },
          ),
          if (_isLoading)
            Center(
              child:
                  CircularProgressIndicator(), // Show the circular progress indicator while loading
            ),
        ],
      ),
    );
  }
}
