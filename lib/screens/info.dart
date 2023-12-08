import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottom_bar.dart';
import 'package:animal_lovers_app/widgets/longCard.dart';
import 'package:animal_lovers_app/screens/donate.dart';
import 'package:animal_lovers_app/screens/profile.dart';
import 'package:animal_lovers_app/widgets/side_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class InfoPage extends StatefulWidget {
  InfoPage({Key? key}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  CollectionReference _referenceInfoList =
      FirebaseFirestore.instance.collection('info');
  late Stream<QuerySnapshot> _streamInfoItems;

  @override
  initState() {
    super.initState();
    _streamInfoItems = _referenceInfoList.snapshots();
  }

  void navigateDonate() {
    //navigate to donate page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => const DonatePage()));
  }

  void navigateInfo() {
    //pop drawer
    Navigator.pop(context);

    //navigate to info page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => InfoPage()));
  }

  void navigateProfile() {
    //pop drawer
    Navigator.pop(context);

    //navigate to profile page
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => ProfilePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Info",
      ),
      drawer: SideBar(),
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
                    stream: _streamInfoItems,
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
                                  'title': e["title"],
                                  'url': e['url']
                                })
                            .toList();
                        return Container(
                          height: MediaQuery.of(context)
                              .size
                              .height, // Provide a fixed height
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (BuildContext context, int index) {
                              Map thisItem = items[index];
                              String url = thisItem['url'];
                              String title = thisItem['title'];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: LongCard(
                                  url: url,
                                  text: title,
                                ),
                              );
                            },
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
