import 'dart:async';

import 'package:animal_lovers_app/screens/species_info.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeciesPage extends StatefulWidget {
  const SpeciesPage({Key? key}) : super(key: key);

  @override
  State<SpeciesPage> createState() => _SpeciesPageState();
}

class _SpeciesPageState extends State<SpeciesPage> {
  List<Map<String, String>> animals = [];

  ScrollController scrollController = ScrollController();
  final _animalnameController = TextEditingController();
  bool noResults = false;
  Set<String> favoriteSpecies = Set<String>();
  late String name;
  late bool isFavorite;
  // Timer variable for debouncing
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch data for animals in Asia on page load
    loadFavoriteSpecies(); // Load favorite species from database
  }

  void loadFavoriteSpecies() async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      return;
    }

    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userSnapshot.exists) {
      final favoriteSpeciesList =
          userSnapshot['favouriteSpeciesList'] as List<dynamic>?;

      if (favoriteSpeciesList != null) {
        setState(() {
          favoriteSpecies = Set<String>.from(
            favoriteSpeciesList.map((item) => item['commonName'] as String),
          );
        });
      }
    }
  }

  void toggleFavoriteStatus(Map<String, String> animal) async {
    String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (currentUserId.isEmpty) {
      return;
    }

    String animalname = name ?? '';
    String commonName = animal['commonName'] ?? '';
    String scientificName = animal['scientificName'] ?? '';

    // Create a map representing the name and common name
    Map<String, String> favoriteItem = {
      'name': animalname,
      'commonName': commonName,
      'scientificName': scientificName,
    };

    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    // Check if the favorite item already exists in the list
    bool isFavorite = favoriteSpecies.contains(animal['commonName']);

    if (isFavorite) {
      // Remove the favorite item from the list using FieldValue.arrayRemove
      await userRef.update({
        'favouriteSpeciesList': FieldValue.arrayRemove([favoriteItem]),
      });
    } else {
      // Add the favorite item to the list using FieldValue.arrayUnion
      await userRef.update({
        'favouriteSpeciesList': FieldValue.arrayUnion([favoriteItem]),
      });
    }

    setState(() {
      // Update the local state to reflect the changes
      if (isFavorite) {
        favoriteSpecies.remove(animal['commonName']);
      } else {
        favoriteSpecies.add(animal['commonName']!);
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
  }

  void fetchData() async {
    const apiKey = 'BRV2D7EBW3C9h5vN2hWbnA==uEFFV3i0ZlYaFHgW';
    name = _animalnameController.text.isNotEmpty == true
        ? _animalnameController.text.trim()
        : '';

    final apiUrl = 'https://api.api-ninjas.com/v1/animals?name=$name';

    final response = await http.get(Uri.parse(apiUrl), headers: {
      'X-Api-Key': apiKey,
    });

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData is List) {
        final asiaAnimals = jsonData.where((animal) {
          final locations = animal['locations'];
          return locations != null && locations.contains('Asia');
        }).toList();
        setState(() {
          animals = asiaAnimals.map<Map<String, String>>((animal) {
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
          }).toList();

          animals.sort((a, b) => a['commonName']!.compareTo(b['commonName']!));

          // Check if there are no results
          noResults = animals.isEmpty;
        });
      } else {
        // Handle the case where the response is not a List
        print('Failed to load data. Invalid response format.');
      }
    } else {
      // Handle the case where the HTTP request fails.
      print('Failed to load data. Status code: ${response.statusCode}');
      print('Response body: ${response.body}');
      noResults = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Species",
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Container(
              height: 60,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: TextField(
                  controller: _animalnameController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 25.0, vertical: 12.0),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Styles.secondaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    fillColor: Styles.secondaryColor,
                    filled: true,
                    hintText: 'Search...',
                    hintStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    // Cancel the previous timer if it exists
                    _debounceTimer?.cancel();

                    // Start a new timer with a 1-second delay to fetch data
                    _debounceTimer = Timer(Duration(seconds: 1), () {
                      fetchData();
                    });
                  },
                ),
              ),
            ),
            // Conditionally render the message if there are no results
            if (noResults)
              Center(
                child: Text(
                  'No Result Found!',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            if (_animalnameController.text.trim().isEmpty)
              Center(
                child: Text(
                  'Please enter the species name.',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true, // Set shrinkWrap to true
                    itemCount: animals.length,
                    itemBuilder: (context, index) {
                      final animal = animals[index];
                      final isAnimalFavorite =
                          favoriteSpecies.contains(animal['commonName']);
                      return GestureDetector(
                        onTap: () {
                          // Navigate to SpeciesInfoPage and pass the species data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SpeciesInfoPage(
                                  speciesData: animal,
                                  toggleFavoriteStatus: () =>
                                      toggleFavoriteStatus(animal)),
                            ),
                          );
                        },
                        child: Card(
                          child: ListTile(
                            title: Text(animal['commonName'] ?? 'Unknown'),
                            subtitle:
                                Text(animal['scientificName'] ?? 'Unknown',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                    )),
                            trailing: IconButton(
                              icon: Icon(
                                isAnimalFavorite
                                    ? Icons.star
                                    : Icons.star_border,
                                color: Styles.primaryColor,
                              ),
                              onPressed: () {
                                toggleFavoriteStatus(animal);
                              },
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
