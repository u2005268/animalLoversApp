import 'package:flutter/material.dart';
import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:gap/gap.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animal_lovers_app/screens/observation_Info.dart';

class Place with ClusterItem {
  final String name;
  final LatLng latLng;
  final Map<String, dynamic> observationDetails;
  final String observationId;
  bool isStarred;

  Place({
    required this.name,
    required this.latLng,
    required this.observationDetails,
    required this.observationId,
    required this.isStarred,
  });

  @override
  LatLng get location => latLng;
}

class ObservationDetailsBottomSheet extends StatefulWidget {
  final Place observation;
  final String username;
  final String currentUserId;
  final Function(bool) updateIsStarred;

  ObservationDetailsBottomSheet({
    Key? key,
    required this.observation,
    required this.username,
    required this.updateIsStarred,
    required this.currentUserId,
  }) : super(key: key);

  @override
  _ObservationDetailsBottomSheetState createState() =>
      _ObservationDetailsBottomSheetState();
}

class _ObservationDetailsBottomSheetState
    extends State<ObservationDetailsBottomSheet> {
  @override
  void initState() {
    super.initState();
    _updateStarStatus();
  }

  @override
  Widget build(BuildContext context) {
    String combinedDateTime =
        '${widget.observation.observationDetails['date']} ${widget.observation.observationDetails['time']}';
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setModalState) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: NetworkImage(
                            widget.observation.observationDetails['imageUrl']),
                      ),
                    ],
                  ),
                  Gap(10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget
                              .observation.observationDetails['whatDidYouSee'],
                          style: TextStyle(
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 16),
                            Gap(5),
                            Text(
                              widget.observation.observationDetails['location']
                                  .split(',')
                                  .first
                                  .trim(),
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.calendar_month_outlined, size: 16),
                            Gap(5),
                            Text(
                              combinedDateTime,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.person_3_outlined, size: 16),
                            Gap(5),
                            Text(
                              widget.username,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.observation.isStarred
                              ? Icons.star
                              : Icons.star_border,
                          color: Styles.primaryColor,
                        ),
                        onPressed: () {
                          toggleStarStatus();
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.info_outline,
                          color: Styles.primaryColor,
                        ),
                        onPressed: () {
                          // Navigate to ObservationInfoPage
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ObservationInfoPage(
                                imageUrl: widget
                                    .observation.observationDetails['imageUrl'],
                                whatDidYouSee: widget.observation
                                    .observationDetails['whatDidYouSee'],
                                location: widget
                                    .observation.observationDetails['location'],
                                combinedDateTime: combinedDateTime,
                                additionalInformation:
                                    widget.observation.observationDetails[
                                        'additionalInformation'],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStarStatus() async {
    bool isStarred =
        await _isObservationStarred(widget.currentUserId, widget.observation);

    // Update the UI to reflect the star status
    setState(() {
      widget.observation.isStarred = isStarred;
    });
  }

  Future<void> _toggleObservationStar(
      String currentUserId, Place observation, BuildContext context) async {
    // Check if the observation is already in the user's favouriteObservationList
    bool isStarred = await _isObservationStarred(currentUserId, observation);

    // Update the user's document in Firestore based on the observation's status
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);

    try {
      if (isStarred) {
        // Remove the observation ID from the list
        await userRef.update({
          'favouriteObservationList':
              FieldValue.arrayRemove([observation.observationId])
        });
      } else {
        // Add the observation ID to the list
        await userRef.update({
          'favouriteObservationList':
              FieldValue.arrayUnion([observation.observationId])
        });
      }

      // Use setState to rebuild the bottom sheet and update the UI
      setState(() {
        observation.isStarred = !isStarred; // Toggle the local star status
      });

      // Show the Snackbar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isStarred ? "Removed from Favourites" : "Saved to Favourites",
        ),
        duration: Duration(seconds: 2),
      ));
    } catch (error) {
      print('Error toggling star status: $error');
    }
  }

  void toggleStarStatus() async {
    bool newStarredState = !widget.observation.isStarred;

    // Update the UI immediately
    setState(() {
      widget.observation.isStarred = newStarredState;
    });

    // Call the callback function to notify the parent widget
    widget.updateIsStarred(newStarredState);

    // Toggle the star status in Firestore
    await _toggleObservationStar(
        widget.currentUserId, widget.observation, context);
  }

  Future<bool> _isObservationStarred(
      String currentUserId, Place observation) async {
    // Fetch the user's document
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();

    if (userSnapshot.exists) {
      final data = userSnapshot.data() as Map<String, dynamic>;
      List<dynamic> favouriteList = data['favouriteObservationList'] ?? [];

      return favouriteList.contains(observation.observationId);
    } else {
      // User document doesn't exist, return false
      return false;
    }
  }
}
