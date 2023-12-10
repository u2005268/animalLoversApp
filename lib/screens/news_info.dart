import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NewsInfoPage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String description;

  NewsInfoPage({
    required this.imageUrl,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: title,
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
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                height: 200, // Adjust the height as needed
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrl), // Use your image URL here
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(15),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14.0,
                    ),
                    textAlign: TextAlign.justify, // Align text to justify
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
