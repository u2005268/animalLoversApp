import 'package:animal_lovers_app/screens/edit_news.dart';
import 'package:animal_lovers_app/screens/news.dart';
import 'package:animal_lovers_app/screens/news_info.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewsCard extends StatelessWidget {
  final NewsItem newsItem;
  final Function() onStarToggle;
  final bool showEditIcon;

  const NewsCard({
    Key? key,
    required this.newsItem,
    required this.onStarToggle,
    required this.showEditIcon,
  }) : super(key: key);

  Future<void> onEditPressed(BuildContext context) async {
    // Navigate to EditDonatePage and pass data
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNewsPage(
          newsId: newsItem.id,
          title: newsItem.title,
          description: newsItem.description,
          timestamp: newsItem.timestamp,
          imageUrl: newsItem.imageUrl,
          // Pass other necessary data
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final newsTimestamp = newsItem.timestamp;
    final newsTime = newsTimestamp.toDate();
    final timeDifference = DateTime.now().difference(newsTime);

    String timeAgo;

    if (timeDifference.inDays >= 365) {
      final years = (timeDifference.inDays / 365).floor();
      timeAgo = '$years ${years == 1 ? 'year' : 'years'}';
    } else if (timeDifference.inDays >= 30) {
      final months = (timeDifference.inDays / 30).floor();
      timeAgo = '$months ${months == 1 ? 'month' : 'months'}';
    } else if (timeDifference.inDays >= 1) {
      timeAgo =
          '${timeDifference.inDays} ${timeDifference.inDays == 1 ? 'day' : 'days'}';
    } else if (timeDifference.inHours >= 1) {
      timeAgo =
          '${timeDifference.inHours} ${timeDifference.inHours == 1 ? 'hour' : 'hours'}';
    } else if (timeDifference.inMinutes >= 1) {
      timeAgo =
          '${timeDifference.inMinutes} ${timeDifference.inMinutes == 1 ? 'minute' : 'minutes'}';
    } else {
      timeAgo =
          '${timeDifference.inSeconds} ${timeDifference.inSeconds == 1 ? 'second' : 'seconds'}';
    }

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        height: 360,
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
            // Navigate to the NewsInfoPage when the card is tapped
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => NewsInfoPage(
                  imageUrl: newsItem.imageUrl,
                  title: newsItem.title,
                  description: newsItem.description,
                ),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  child: Stack(
                    children: [
                      Image.network(
                        newsItem.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 200,
                      ),
                      if (showEditIcon)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Styles
                                  .secondaryColor, // Green background color
                            ),
                            child: IconButton(
                              icon:
                                  Icon(Icons.edit, color: Styles.primaryColor),
                              onPressed: () async {
                                await onEditPressed(context);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        newsItem.title,
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Gap(8),
                      Text(
                        newsItem.description,
                        style: TextStyle(
                          fontSize: 14.0,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 5,
                      ),
                      Gap(10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(timeAgo),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    newsItem.isStarred
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Styles.primaryColor,
                                  ),
                                  onPressed: () {
                                    onStarToggle();
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
