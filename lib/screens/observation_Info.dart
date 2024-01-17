import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ObservationInfoPage extends StatelessWidget {
  final String whatDidYouSee;
  final String location;
  final String combinedDateTime;
  final String additionalInformation;
  final String imageUrl;

  const ObservationInfoPage({
    Key? key,
    required this.whatDidYouSee,
    required this.location,
    required this.combinedDateTime,
    required this.additionalInformation,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the rectangular image
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
            Gap(15),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      whatDidYouSee, // Display the value
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold, // Add bold style
                        shadows: [
                          Shadow(
                            blurRadius: 2.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Gap(15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, size: 16),
                          Gap(5),
                          Text(
                            location.split(',').first.trim(),
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, size: 16),
                          Gap(5),
                          Text(
                            combinedDateTime,
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  Gap(20),
                  Text(
                    additionalInformation,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.justify, // Align text to justify
                  ),
                  // Add more information as needed
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
