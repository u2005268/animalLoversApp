import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/newsCard.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  _NewsPageState createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<NewsItem> newsItems = [];

  @override
  void initState() {
    super.initState();
    fetchNewsData();
  }

  Future<void> fetchNewsData() async {
    // Get the current user's ID
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    // Ensure you have a valid user ID
    if (currentUserId.isEmpty) {
      // Handle the case where there is no logged-in user
      return;
    }

    // Fetch the user's favorite news list
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    List<String> favoriteNewsIds = [];
    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>;
      favoriteNewsIds = List<String>.from(data['favouriteNewsList'] ?? []);
    }

    // Fetch news items and determine if they are starred
    var querySnapshot =
        await FirebaseFirestore.instance.collection('news').get();
    var fetchedNewsItems = querySnapshot.docs.map((doc) {
      bool isStarred = favoriteNewsIds.contains(doc.id);
      return NewsItem(
        id: doc.id,
        imageUrl: doc['imageUrl'],
        title: doc['title'],
        description: doc['description'],
        timestamp: doc['timestamp'],
        isStarred: isStarred,
      );
    }).toList();

    setState(() {
      newsItems = fetchedNewsItems;
    });
  }

  void toggleStarStatus(NewsItem newsItem) async {
    // Again, get the current user's ID
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      // Handle the case where there is no logged-in user
      return;
    }

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    if (newsItem.isStarred) {
      await userRef.update({
        'favouriteNewsList': FieldValue.arrayRemove([newsItem.id])
      });
    } else {
      await userRef.update({
        'favouriteNewsList': FieldValue.arrayUnion([newsItem.id])
      });
    }

    setState(() {
      newsItem.isStarred = !newsItem.isStarred;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newsItem.isStarred
            ? "Added to Favourites"
            : "Removed from Favourites"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(titleText: "News"),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      body: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (BuildContext context, int index) {
          return NewsCard(
            newsItem: newsItems[index],
            onStarToggle: () => toggleStarStatus(newsItems[index]),
          );
        },
      ),
    );
  }
}

class NewsItem {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String timestamp;
  bool isStarred;

  NewsItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isStarred = false,
  });
}
