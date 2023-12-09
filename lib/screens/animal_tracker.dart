import 'package:animal_lovers_app/screens/observation.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalTracker extends StatefulWidget {
  AnimalTracker({Key? key}) : super(key: key);

  @override
  State<AnimalTracker> createState() => _AnimalTrackerState();
}

class _AnimalTrackerState extends State<AnimalTracker> {
  final user = FirebaseAuth.instance.currentUser!;
  GoogleMapController? _mapController;
  Set<Marker> _markers = {}; // Initialize _markers to store markers

  // Kuala Lumpur LatLng
  LatLng _initialLatLng = LatLng(3.1390, 101.6869);

  @override
  void initState() {
    super.initState();
    _loadObservations();
  }

  Future<void> _loadObservations() async {
    Set<Marker> markers = {}; // Initialize a new set to store markers

    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('observations').get();
    snapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final LatLng location = LatLng(
        data['latitude']?.toDouble() ?? 0.0,
        data['longitude']?.toDouble() ?? 0.0,
      );

      // Create a marker for this place and add it to the markers set
      final marker = Marker(
        markerId: MarkerId(location.toString()), // Use LatLng as markerId
        position: location,
        onTap: () {
          _showObservationDetails(data);
        },
      );
      markers.add(marker);
    });

    // Update the markers in the state
    setState(() {
      _markers = markers;
    });
  }

  void _showObservationDetails(Map<String, dynamic> observation) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 250,
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                observation['whatDidYouSee'],
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(observation['location']),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: "Animal Tracker",
        actionWidgets: [
          IconButton(
            icon: Icon(
              Icons.add_circle_outline_outlined,
              color: Styles.primaryColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ObservationPage(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: SideBar(),
      bottomNavigationBar: BottomBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
          },
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: _initialLatLng,
            zoom: 10.0,
          ),
        ),
      ),
    );
  }
}
