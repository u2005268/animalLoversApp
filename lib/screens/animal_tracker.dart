import 'dart:ui';
import 'dart:math' as math;
import 'package:animal_lovers_app/screens/observation.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:animal_lovers_app/widgets/bottomBar.dart';
import 'package:animal_lovers_app/widgets/customAppbar.dart';
import 'package:animal_lovers_app/screens/observationBottomSheet.dart';
import 'package:animal_lovers_app/widgets/sideBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnimalTracker extends StatefulWidget {
  AnimalTracker({Key? key}) : super(key: key);

  @override
  State<AnimalTracker> createState() => _AnimalTrackerState();
}

class _AnimalTrackerState extends State<AnimalTracker> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  late ClusterManager<Place> _clusterManager;
  late LatLng _initialLatLng;
  bool isStarred = false;

  @override
  void initState() {
    super.initState();
    _initialLatLng = LatLng(3.1390, 101.6869);
    _clusterManager = _initClusterManager();
    _loadObservations();
  }

  ClusterManager<Place> _initClusterManager() {
    return ClusterManager<Place>(
      [],
      _updateMarkers,
      markerBuilder: _markerBuilder,
    );
  }

  void _updateMarkers(Set<Marker> markers) {
    setState(() {
      _markers = markers;
    });
  }

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        return Marker(
          markerId: MarkerId(cluster.getId()),
          position: cluster.location,
          onTap: () {
            _onMarkerTapped(cluster);
          },
          icon: await _getMarkerBitmap(
            cluster.isMultiple ? 125 : 75,
            text: cluster.isMultiple ? cluster.count.toString() : null,
          ),
        );
      };

  void _onMarkerTapped(Cluster<Place> cluster) {
    if (cluster.isMultiple) {
      _zoomInToCluster(cluster);
    } else {
      _showObservationDetails(context, cluster.items.first);
    }
  }

  void _zoomInToCluster(Cluster<Place> cluster) {
    double minLat = cluster.location.latitude;
    double maxLat = cluster.location.latitude;
    double minLng = cluster.location.longitude;
    double maxLng = cluster.location.longitude;

    for (var place in cluster.items) {
      minLat = math.min(minLat, place.location.latitude);
      maxLat = math.max(maxLat, place.location.latitude);
      minLng = math.min(minLng, place.location.longitude);
      maxLng = math.max(maxLng, place.location.longitude);
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50.0,
      ),
    );
  }

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    if (kIsWeb) size = (size / 2).floor();

    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint1 = Paint()..color = Colors.red;
    final Paint paint2 = Paint()..color = Colors.white;

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.2, paint2);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.8, paint1);

    if (text != null) {
      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
          fontSize: size / 3,
          color: Colors.white,
          fontWeight: FontWeight.normal,
        ),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );
    }

    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  Future<void> _loadObservations() async {
    List<Place> places = [];
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('observations').get();
    snapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final LatLng location = LatLng(
        data['latitude']?.toDouble() ?? 0.0,
        data['longitude']?.toDouble() ?? 0.0,
      );

      places.add(
        Place(
          name: data['placeName'] ?? '',
          latLng: location,
          observationDetails: data,
          observationReference: doc.reference,
          isStarred: false,
        ),
      );
    });

    _clusterManager.setItems(places);
  }

  Future<String> _fetchUsername(String userId) async {
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (userSnapshot.exists) {
      return userSnapshot['username'];
    } else {
      return 'Username not found';
    }
  }

  void _showObservationDetails(BuildContext context, Place observation) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    String currentUserId = currentUser?.uid ?? ''; // Get the current user's ID

    // Fetch the username based on the userId
    String userId =
        observation.observationDetails['userId']; // Modify the key accordingly
    String username = await _fetchUsername(userId);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ObservationDetailsBottomSheet(
          observation: observation,
          username: username,
          currentUserId: currentUserId, // Pass the current user's ID here
          updateIsStarred: (bool newValue) {
            setState(() {
              isStarred = newValue;
            });
          },
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
            _clusterManager.setMapId(controller.mapId);
          },
          markers: _markers,
          initialCameraPosition: CameraPosition(
            target: _initialLatLng,
            zoom: 10.0,
          ),
          onCameraMove: _clusterManager.onCameraMove,
          onCameraIdle: _clusterManager.updateMap,
        ),
      ),
    );
  }
}
