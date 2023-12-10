import 'package:animal_lovers_app/screens/news.dart';
import 'package:animal_lovers_app/screens/news_info.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class NewsCard extends StatelessWidget {
  final NewsItem newsItem;
  final Function() onStarToggle;

  const NewsCard({
    Key? key,
    required this.newsItem,
    required this.onStarToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  height: 150,
                  child: Image.network(
                    newsItem.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
                                Text(newsItem.timestamp),
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
