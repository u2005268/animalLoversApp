import 'package:animal_lovers_app/screens/news.dart';
import 'package:animal_lovers_app/screens/news_info.dart';
import 'package:animal_lovers_app/screens/observation_Info.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FavoriteCard extends StatefulWidget {
  final String title;
  final String imageUrl;
  final bool isFavorite;
  final Function(bool) onToggleFavorite;
  final String itemId;
  final String itemType;

  const FavoriteCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.itemId,
    required this.itemType,
  }) : super(key: key);

  @override
  _FavoriteCardState createState() => _FavoriteCardState();
}

class _FavoriteCardState extends State<FavoriteCard> {
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(FavoriteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update the local state when the isFavorite property changes
    if (widget.isFavorite != isFavorite) {
      setState(() {
        isFavorite = widget.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 0.3,
              blurRadius: 5,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () {
            // Navigate to either NewsInfoPage or ObservationInfoPage based on itemType
            navigateToDetailsPage(context, widget.itemId, widget.itemType);
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    child: Image.network(
                      widget.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            isFavorite = !isFavorite;
                          });
                          widget.onToggleFavorite(isFavorite);
                        },
                        child: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: Styles.primaryColor, // Change color as needed
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Add the navigateToDetailsPage method
void navigateToDetailsPage(
    BuildContext context, String itemId, String itemType) async {
  try {
    // Determine the type of item (news or observation)
    bool isNewsItem = itemType == 'news';

    if (isNewsItem) {
      // Fetch news details by ID
      NewsItem? newsDetails = await fetchNewsDetailsById(itemId);

      if (newsDetails != null) {
        // Navigate to NewsInfoPage with the fetched details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewsInfoPage(
              imageUrl: newsDetails.imageUrl,
              title: newsDetails.title,
              description: newsDetails.description,
            ),
          ),
        );
      }
    } else {
      // Fetch observation details by ID
      ObservationItem? observationDetails =
          await fetchObservationDetailsById(itemId);

      if (observationDetails != null) {
        // Navigate to ObservationInfoPage with the fetched details
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ObservationInfoPage(
              imageUrl: observationDetails.imageUrl,
              whatDidYouSee: observationDetails.whatDidYouSee,
              location: observationDetails.location,
              combinedDateTime:
                  '${observationDetails.date} ${observationDetails.time}',
              additionalInformation: observationDetails.additionalInformation,
            ),
          ),
        );
      }
    }
  } catch (error) {
    print('Error navigating to details page: $error');
  }
}

Future<NewsItem?> fetchNewsDetailsById(String itemId) async {
  try {
    var docSnapshot =
        await FirebaseFirestore.instance.collection('news').doc(itemId).get();

    if (docSnapshot.exists) {
      return NewsItem(
        id: docSnapshot.id,
        imageUrl: docSnapshot['imageUrl'],
        title: docSnapshot['title'],
        description: docSnapshot['description'],
        timestamp: docSnapshot['timestamp'],
      );
    }
  } catch (error) {
    print('Error fetching news item details: $error');
  }

  return null;
}

Future<ObservationItem?> fetchObservationDetailsById(String itemId) async {
  try {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('observations')
        .doc(itemId)
        .get();

    if (docSnapshot.exists) {
      return ObservationItem(
        id: docSnapshot.id,
        imageUrl: docSnapshot['imageUrl'],
        whatDidYouSee: docSnapshot['whatDidYouSee'],
        location: docSnapshot['location'],
        date: docSnapshot['date'],
        time: docSnapshot['time'],
        additionalInformation: docSnapshot['additionalInformation'],
      );
    }
  } catch (error) {
    print('Error fetching observation item details: $error');
  }

  return null;
}

class ObservationItem {
  final String id;
  final String imageUrl;
  final String whatDidYouSee;
  final String location;
  final String date;
  final String time;
  final String additionalInformation;

  ObservationItem({
    required this.id,
    required this.imageUrl,
    required this.whatDidYouSee,
    required this.location,
    required this.date,
    required this.time,
    required this.additionalInformation,
  });
}
