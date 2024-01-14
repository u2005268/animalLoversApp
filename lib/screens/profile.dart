import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:animal_lovers_app/screens/species_info.dart';
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
  List<Map<String, String>> speciesFavorites = [];
  List<Map<String, String>> updatedSpeciesFavorites = [];
  List<String> observationFavorites = [];
  List<String> newsFavorites = [];
  late bool isFavorite;
  late String name;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    if (selectedIndex == 0) {
      // Fetch species favorites only if the selected index is 0
      fetchSpeciesFavorites();
    }
  }

  void fetchSpeciesFavorites() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (currentUserId.isEmpty) {
        return;
      }

      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userSnapshot.exists) {
        final speciesFavoritesList =
            userSnapshot['favouriteSpeciesList'] as List<dynamic>?;

        if (speciesFavoritesList != null) {
          updatedSpeciesFavorites = List<Map<String, String>>.from(
              speciesFavoritesList.map((item) => {
                    'commonName': item['commonName']?.toString() ?? '',
                    'name': item['name']?.toString() ?? '',
                    'scientificName': item['scientificName']?.toString() ?? '',
                  }));

          setState(() {
            speciesFavorites = updatedSpeciesFavorites;
          });
        }
      }
    } catch (error) {
      print('Error fetching species favorites: $error');
    }
  }

  Future<Map<String, String>> fetchSpeciesDetails(String speciesName) async {
    const apiKey = 'BRV2D7EBW3C9h5vN2hWbnA==uEFFV3i0ZlYaFHgW';
    final apiUrl = 'https://api.api-ninjas.com/v1/animals?name=$speciesName';

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-Api-Key': apiKey,
      });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData is List && jsonData.isNotEmpty) {
          final animal = jsonData.first;

          // Create a Map with the species details
          return {
            'commonName': animal['name'] ?? 'Unknown',
            'scientificName':
                animal['taxonomy']['scientific_name'] ?? 'Unknown',
            'class': animal['taxonomy']['class'] ?? 'Unknown',
            'order': animal['taxonomy']['order'] ?? 'Unknown',
            'main_prey': animal['characteristics']['main_prey'] ?? 'Unknown',
            'habitat': animal['characteristics']['habitat'] ?? 'Unknown',
            'predators': animal['characteristics']['predators'] ?? 'Unknown',
            'diet': animal['characteristics']['diet'] ?? 'Unknown',
            'favorite_food':
                animal['characteristics']['favorite_food'] ?? 'Unknown',
            'color': animal['characteristics']['color'] ?? 'Unknown',
            'skin_type': animal['characteristics']['skin_type'] ?? 'Unknown',
            'lifespan': animal['characteristics']['lifespan'] ?? 'Unknown',
          };
        }
      } else {
        print(
            'Failed to fetch species details. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error) {
      print('Error fetching species details: $error');
    }

    // Return an empty map in case of an error
    return {};
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
          List<Map<String, String>> speciesFavorites =
              (userData?['speciesFavorites'] as List<dynamic>?)
                      ?.map((item) => {
                            'commonName': item['commonName']?.toString() ?? '',
                            'name': item['name']?.toString() ?? '',
                            'scientificName':
                                item['scientificName']?.toString() ?? '',
                          })
                      .toList()
                      .cast<Map<String, String>>() ??
                  [];

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

  void toggleSpeciesFavoriteStatus(String speciesCommonName) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      return;
    }

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    try {
      // Fetch the current user's species favorites from the database
      DocumentSnapshot userSnapshot = await userRef.get();
      List<dynamic>? speciesFavoritesList =
          userSnapshot['favouriteSpeciesList'] as List<dynamic>?;

      // Check if the favorite item already exists in the list
      bool isFavorite = speciesFavoritesList?.any(
            (item) => item['commonName'] == speciesCommonName,
          ) ??
          false;

      if (isFavorite) {
        // Remove the entire item from the list
        speciesFavoritesList!
            .removeWhere((item) => item['commonName'] == speciesCommonName);

        // Update the user's document in the Firestore with the modified list
        await userRef.update({
          'favouriteSpeciesList': speciesFavoritesList,
        });
      } else {
        // Add the favorite item to the list using FieldValue.arrayUnion
        await userRef.update({
          'favouriteSpeciesList': FieldValue.arrayUnion([
            {
              'commonName': speciesCommonName,
              // Add other fields if needed
            }
          ]),
        });
      }

      // Fetch the updated species favorites from the database
      userSnapshot = await userRef.get();
      speciesFavoritesList =
          userSnapshot['favouriteSpeciesList'] as List<dynamic>?;

      setState(() {
        // Update the local state to reflect the changes
        if (speciesFavoritesList != null) {
          speciesFavorites = List<Map<String, String>>.from(
            speciesFavoritesList.map((item) => {
                  'commonName': item['commonName']?.toString() ?? '',
                  'name': item['name']?.toString() ?? '',
                  'scientificName': item['scientificName']?.toString() ?? '',
                }),
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isFavorite ? "Removed from Favorites" : "Added to Favorites",
          ),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (error) {
      print('Error toggling species favorite status: $error');
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
                      child: selectedIndex != 0
                          ? Column(
                              children: buildFavoriteCards(),
                            )
                          : Column(
                              children: [
                                // Your existing logic for other items when selectedIndex is 0
                                // For example, display ListTiles
                                if (speciesFavorites.isNotEmpty)
                                  ...speciesFavorites.map((speciesFavorite) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: GestureDetector(
                                        onTap: () async {
                                          // Fetch species details before navigating to SpeciesInfoPage
                                          Map<String, String> speciesDetails =
                                              await fetchSpeciesDetails(
                                                  speciesFavorite['name']!);

                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  SpeciesInfoPage(
                                                speciesData: speciesDetails,
                                                toggleFavoriteStatus: () {
                                                  toggleSpeciesFavoriteStatus(
                                                      speciesFavorite[
                                                          'commonName']!);
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                        child: Card(
                                          child: ListTile(
                                            title: Text(
                                                speciesFavorite['commonName'] ??
                                                    'Unknown'),
                                            subtitle: Text(
                                              speciesFavorite[
                                                      'scientificName'] ??
                                                  'Unknown',
                                              style: TextStyle(
                                                  fontStyle: FontStyle.italic),
                                            ),
                                            trailing: IconButton(
                                              icon: Icon(
                                                speciesFavorites.contains(
                                                        speciesFavorite[
                                                            'commonName'])
                                                    ? Icons.star_border
                                                    : Icons.star,
                                                color: Styles.primaryColor,
                                              ),
                                              onPressed: () {
                                                toggleSpeciesFavoriteStatus(
                                                    speciesFavorite[
                                                        'commonName']!);
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                if (speciesFavorites.isEmpty)
                                  Text(
                                    'No Record Found!',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                              ],
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
