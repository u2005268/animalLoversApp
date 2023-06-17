import 'package:animal_lovers_app/components/donationCard.dart';
import 'package:animal_lovers_app/components/shortButton.dart';
import 'package:animal_lovers_app/screens/info.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/screens/side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DonatePage extends StatefulWidget {
  const DonatePage({Key? key}) : super(key: key);

  @override
  State<DonatePage> createState() => _DonatePageState();
}

class _DonatePageState extends State<DonatePage> {
  CollectionReference _referenceDonationList =
      FirebaseFirestore.instance.collection('donation');
  late Stream<QuerySnapshot> _streamDonationItems;

  @override
  initState() {
    super.initState();
    _streamDonationItems = _referenceDonationList.snapshots();
  }

  void navigateDonate() {
    // navigate to donate page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DonatePage()));
  }

  void navigateInfo() {
    // pop drawer
    Navigator.pop(context);

    // navigate to info page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InfoPage()));
  }

  void navigateProfile() {
    // pop drawer
    Navigator.pop(context);

    // navigate to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Text(
          "Donate",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            shadows: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                offset: Offset(0, 1),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        // Set the icon color to black,
      ),
      drawer: SideBar(
        onDonateTap: navigateDonate,
        onInfoTap: navigateInfo,
        onProfileTap: navigateProfile,
      ),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.3646, 0.9062, 1.0],
            colors: [
              Colors.white,
              Colors.white,
              Color.fromRGBO(182, 255, 182, 0.5),
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _streamDonationItems,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              // Handle any errors
              return AlertDialog(
                title: Text('Error: ${snapshot.error}'),
              );
            } else if (snapshot.hasData) {
              // Handle the snapshot data
              QuerySnapshot querySnapshot = snapshot.data;
              List<QueryDocumentSnapshot> documents = querySnapshot.docs;

              List<Map> items = documents
                  .map((e) => {
                        'id': e.id,
                        'image': e["image"],
                        'title': e['title'],
                        'logoImage': e['logoImage'],
                        'name': e['name'],
                        'url': e['url']
                      })
                  .toList();

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: MediaQuery.of(context)
                          .size
                          .height, // Provide a fixed height
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (BuildContext context, int index) {
                          Map thisItem = items[index];
                          String image = thisItem['image'];
                          String title = thisItem['title'];
                          String logoImage = thisItem['logoImage'];
                          String name = thisItem['name'];
                          String url = thisItem['url'];
                          return DonationCard(
                            image: image,
                            title: title,
                            logoImage: logoImage,
                            name: name,
                            url: url,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Show a loading indicator while waiting for data
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    );
  }
}
