import 'package:animal_lovers_app/screens/animal_tracker.dart';
import 'package:animal_lovers_app/screens/observation.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/longCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class ObservationHistoryPage extends StatefulWidget {
  const ObservationHistoryPage({Key? key}) : super(key: key);

  @override
  State<ObservationHistoryPage> createState() => _ObservationHistoryPageState();
}

class _ObservationHistoryPageState extends State<ObservationHistoryPage> {
  CollectionReference _referenceObservationList =
      FirebaseFirestore.instance.collection('observations');
  late Stream<QuerySnapshot> _streamObservationItems;

  @override
  initState() {
    super.initState();
    final currentUser = FirebaseAuth.instance.currentUser;
    final userId = currentUser?.uid; // Get the user's ID
    // Create a query that filters observations by the user's ID
    _streamObservationItems = _referenceObservationList
        .where('userId', isEqualTo: userId)
        .snapshots();
  }

  // Function to parse the date and time
  DateTime parseDateAndTime(String dateAndTimeStr) {
    // Define the date and time format
    final DateFormat dateFormat = DateFormat("dd-MM-yyyy HH:mm:ss");
    // Parse the string into a DateTime object
    return dateFormat.parse(dateAndTimeStr);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "My Observation",
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AnimalTracker()),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: Container(
          height: MediaQuery.of(context).size.height,
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Gap(20),
                  StreamBuilder<QuerySnapshot>(
                    stream: _streamObservationItems,
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      // Add your StreamBuilder UI code here
                      if (snapshot.hasError) {
                        // Handle any errors
                        return AlertDialog(
                          title: Text('Error: ${snapshot.error}'),
                        );
                      } else if (snapshot.hasData) {
                        // Handle the snapshot data
                        QuerySnapshot querySnapshot = snapshot.data;
                        List<QueryDocumentSnapshot> documents =
                            querySnapshot.docs;

                        List<Map> items = documents
                            .map((e) => {
                                  'id': e.id,
                                  'imageUrl': e["imageUrl"] ?? "",
                                  'whatDidYouSee': e["whatDidYouSee"] ?? "",
                                  'location': e['location'] ?? "",
                                  'date': e['date'] ?? "",
                                  'time': e['time'] ?? "",
                                })
                            .toList();

                        if (items.isEmpty) {
                          // No observations found
                          return Center(
                            child: Text(
                              'No Record Found!',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }

                        // Sort the items list based on date and time in descending order
                        items.sort((a, b) {
                          DateTime dateTimeA =
                              parseDateAndTime(a['date'] + ' ' + a['time']);
                          DateTime dateTimeB =
                              parseDateAndTime(b['date'] + ' ' + b['time']);
                          return dateTimeB.compareTo(dateTimeA);
                        });
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: MediaQuery.of(context)
                                .size
                                .height, // Provide a fixed height
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map thisItem = items[index];
                                String whatDidYouSee =
                                    thisItem['whatDidYouSee'];
                                String location = thisItem['location'];
                                String date = thisItem['date'];
                                String time = thisItem['time'];
                                String imageUrl = thisItem['imageUrl'];

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10.0),
                                  child: LongCard(
                                    text1: whatDidYouSee,
                                    text2: location,
                                    text3: '$date $time',
                                    imageUrl: imageUrl,
                                    onEditPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ObservationPage(
                                                  observationId: thisItem[
                                                      'id'], // Pass the observation ID
                                                )),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      } else {
                        // Show a loading indicator while waiting for data
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
