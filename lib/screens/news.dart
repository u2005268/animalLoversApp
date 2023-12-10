import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/newsCard.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // Create a list to store news data
  List<NewsItem> newsItems = [];

  // Function to fetch news data from Firestore
  void fetchNewsData() {
    FirebaseFirestore.instance
        .collection(
            'news') // Replace 'news' with your Firestore collection name
        .get()
        .then((QuerySnapshot querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        // Convert Firestore document data to a NewsItem object
        NewsItem newsItem = NewsItem(
          imageUrl: doc['imageUrl'],
          title: doc['title'],
          description: doc['description'],
          timestamp: doc['timestamp'],
        );

        // Add the NewsItem to the list
        setState(() {
          newsItems.add(newsItem);
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Fetch news data when the widget is initialized
    fetchNewsData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "News",
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (BuildContext context, int index) {
          return NewsCard(
            imageUrl: newsItems[index].imageUrl,
            title: newsItems[index].title,
            description: newsItems[index].description,
            timestamp: newsItems[index].timestamp,
          );
        },
      ),
    );
  }
}

class NewsItem {
  final String imageUrl;
  final String title;
  final String description;
  final String timestamp;

  NewsItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}
