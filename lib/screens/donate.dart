import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/donationCard.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Donate",
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
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
