import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/favouriteCard.dart';
import 'package:animal_lovers_app/widgets/shortButton.dart';
import 'package:animal_lovers_app/screens/edit_profile.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  String? bio;
  String? photoUrl;
  final currentUser = FirebaseAuth.instance.currentUser!;
  int selectedIndex = 0;
  List<Observation> observationFavoritesDetails = [];
  List<News> newsFavoritesDetails = [];
  // Lists to store favorite items for each category
  List<String> speciesFavorites = [];
  List<String> observationFavorites = [];
  List<String> newsFavorites = [];
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userId = currentUser.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data();
        setState(() {
          username = userData?['username'];
          bio = userData?['bio'];
          photoUrl = userData?['photoUrl'];
        });
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  String getBioText() {
    if (bio == null || bio!.isEmpty) {
      return 'You do not have any bio yet. Do add it by tapping the edit icon button';
    }
    return bio!;
  }

  String getPhotoUrl() {
    if (photoUrl == null || photoUrl!.isEmpty) {
      return 'assets/images/user.png'; // Replace with the asset image path
    }
    return photoUrl!;
  }

  void navigateEditProfile() async {
    // Navigate to edit profile page
    final updatedUserData = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          username: username ?? '',
          email: currentUser.email!,
          bio: bio ?? '',
          photoUrl: photoUrl ?? '',
          onProfileUpdated: handleProfileUpdated,
        ),
      ),
    );

    if (updatedUserData != null) {
      setState(() {
        bio = updatedUserData['bio'];
        photoUrl = updatedUserData['photoUrl'];
      });
    }
  }

  void handleProfileUpdated(String? updatedBio, String? updatedPhotoUrl) {
    setState(() {
      bio = updatedBio;
      photoUrl = updatedPhotoUrl;
    });
  }

  Future<void> fetchFavoriteItems(int index) async {
    try {
      final userId = currentUser.uid;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (snapshot.exists) {
        final userData = snapshot.data();
        setState(() {
          speciesFavorites =
              List<String>.from(userData?['speciesFavorites'] ?? []);
          observationFavorites =
              List<String>.from(userData?['favouriteObservationList'] ?? []);
          newsFavorites =
              List<String>.from(userData?['favouriteNewsList'] ?? []);
          selectedIndex = index;
        });
      }

      if (selectedIndex == 1) {
        // Fetch observation details for the observation favorites
        final observationDetails =
            await fetchObservationDetails(observationFavorites);
        setState(() {
          observationFavoritesDetails = observationDetails;
        });
      } else if (selectedIndex == 2) {
        // Fetch news details for the news favorites
        final newsDetails = await fetchNewsDetails(newsFavorites);
        setState(() {
          newsFavoritesDetails = newsDetails;
        });
      }
    } catch (error) {
      print('Error fetching favorite items: $error');
    }
  }

  Future<List<Observation>> fetchObservationDetails(
      List<String> observationIds) async {
    final observationDetails = <Observation>[];

    try {
      for (final observationId in observationIds) {
        final observationDoc = await FirebaseFirestore.instance
            .collection('observations')
            .doc(observationId)
            .get();

        if (observationDoc.exists) {
          final observationData = observationDoc.data() as Map<String, dynamic>;
          final observation = Observation(
            id: observationId,
            imageUrl: observationData['imageUrl'] ?? '',
            whatDidYouSee:
                observationData['whatDidYouSee'] ?? '', // Corrected field name
          );

          observationDetails.add(observation);
        }
      }
    } catch (error) {
      print('Error fetching observation details: $error');
    }

    return observationDetails;
  }

  Future<List<News>> fetchNewsDetails(List<String> newsIds) async {
    final newsDetails = <News>[];

    try {
      for (final newsId in newsIds) {
        final newsDoc = await FirebaseFirestore.instance
            .collection('news')
            .doc(newsId)
            .get();

        if (newsDoc.exists) {
          final newsData = newsDoc.data() as Map<String, dynamic>;
          final news = News(
            id: newsId,
            imageUrl: newsData['imageUrl'] ?? '',
            title: newsData['title'] ?? '', // Corrected field name
          );

          newsDetails.add(news);
        }
      }
    } catch (error) {
      print('Error fetching news details: $error');
    }

    return newsDetails;
  }

  void toggleFavoriteStatus(String itemId, bool isFavorite) async {
    try {
      final userId = currentUser.uid;
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Toggle observation or news favorite status
      if (isFavorite) {
        await userRef.update({
          selectedIndex == 1 ? 'favouriteObservationList' : 'favouriteNewsList':
              FieldValue.arrayUnion([itemId])
        });
        isFavorite = !isFavorite;
      } else {
        await userRef.update({
          selectedIndex == 1 ? 'favouriteObservationList' : 'favouriteNewsList':
              FieldValue.arrayRemove([itemId])
        });
        isFavorite = !isFavorite;
      }

      // Show a snackbar indicating whether the item was added or removed from favorites
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isFavorite ? "Removed from Favourites" : "Added to Favourites"),
          duration: Duration(seconds: 2),
        ),
      );

      // Fetch the latest data and update the UI again
      setState(() {
        fetchFavoriteItems(selectedIndex);
      });
    } catch (error) {
      print('Error toggling favorite status: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "",
        actionWidgets: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Styles.primaryColor,
            ),
            onPressed: navigateEditProfile,
          )
        ],
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Container(
            color: Colors.white,
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey[400] ?? Colors.transparent,
                        width: 1.0, // Customize the border width here
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: photoUrl != null && photoUrl!.isNotEmpty
                          ? Image.network(
                              photoUrl!,
                              // Specify any additional properties for the network image if needed
                            )
                          : Image.asset(
                              'images/user.png', // Replace with the asset image path
                              // Specify any additional properties for the asset image if needed
                            ),
                    ),
                  ),
                  Text(
                    username ?? '',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(5),
                  Text(
                    currentUser.email!,
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                  Gap(10),
                  Container(
                    width: 450,
                    height: 80,
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Styles.primaryColor,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Text(
                      getBioText(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Gap(40),
                  Text(
                    "My Favourites",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  Gap(10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ShortButton(
                            buttonText: "Species",
                            isTapped: selectedIndex == 0,
                            width: 90,
                            onTap: () {
                              fetchFavoriteItems(0);
                            },
                          ),
                          Gap(30),
                          ShortButton(
                            buttonText: "Observation",
                            isTapped: selectedIndex == 1,
                            width: 90,
                            onTap: () {
                              fetchFavoriteItems(1);
                            },
                          ),
                          Gap(30),
                          ShortButton(
                            buttonText: "News",
                            isTapped: selectedIndex == 2,
                            width: 90,
                            onTap: () {
                              fetchFavoriteItems(2);
                            },
                          ),
                        ]),
                  ),
                  Gap(20), // Add some spacing
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: buildFavoriteCards(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> buildFavoriteCards() {
    List<FavoriteItem> favoriteItems = [];

    // Determine which favorite list to use based on the selected button
    if (selectedIndex == 1) {
      favoriteItems = observationFavoritesDetails
          .map((observation) => FavoriteItem(
                itemId: observation.id,
                itemType: 'observation',
                title: observation.whatDidYouSee,
                imageUrl: observation.imageUrl,
                isFavorite: observationFavorites.contains(observation.id),
                onToggleFavorite: (isFavorite) {
                  toggleFavoriteStatus(observation.id, isFavorite);
                },
              ))
          .toList();
    } else if (selectedIndex == 2) {
      favoriteItems = newsFavoritesDetails
          .map((news) => FavoriteItem(
                itemId: news.id,
                itemType: 'news',
                title: news.title,
                imageUrl: news.imageUrl,
                isFavorite: newsFavorites.contains(news.id),
                onToggleFavorite: (isFavorite) {
                  toggleFavoriteStatus(news.id, isFavorite);
                },
              ))
          .toList();
    }

    // Check if the newsDetails list is empty
    if ((selectedIndex == 1 && observationFavoritesDetails.isEmpty) ||
        (selectedIndex == 2 && newsFavoritesDetails.isEmpty)) {
      return [
        const Text(
          'No Record Found!',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
      ];
    }

    // Create a list of cards based on the selected favorite list
    List<Widget> cards = favoriteItems.map((favorite) {
      return FavoriteCard(
        title: favorite.title,
        imageUrl: favorite.imageUrl,
        isFavorite: favorite.isFavorite,
        itemId: favorite.itemId, // Pass itemId
        itemType: favorite.itemType, // Pass itemType
        onToggleFavorite: (isFavorite) {
          // Update the state using setState
          setState(() {
            favorite.isFavorite = isFavorite;
          });
          // Call the actual callback
          favorite.onToggleFavorite(isFavorite);
        },
      );
    }).toList();

    return cards;
  }
}

class FavoriteItem {
  final String title;
  final String imageUrl;
  final String itemId;
  final String itemType;
  bool isFavorite;
  final Function(bool) onToggleFavorite;

  FavoriteItem({
    required this.title,
    required this.imageUrl,
    required this.itemId,
    required this.itemType,
    this.isFavorite = true,
    required this.onToggleFavorite,
  });

  void toggleFavorite() {
    isFavorite = !isFavorite;
    onToggleFavorite(isFavorite);
  }
}

class Observation {
  final String id;
  final String imageUrl;
  final String whatDidYouSee;
  String itemType;

  Observation({
    required this.id,
    required this.imageUrl,
    required this.whatDidYouSee,
    this.itemType = "observation",
  });
}

class News {
  final String id;
  final String imageUrl;
  final String title;
  String itemType;
  News({
    required this.id,
    required this.imageUrl,
    required this.title,
    this.itemType = "news",
  });
}
