import 'package:animal_lovers_app/utils/app_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapBottomSheet extends StatefulWidget {
  final void Function(String, double, double) onLocationSelected;
  const GoogleMapBottomSheet({Key? key, required this.onLocationSelected})
      : super(key: key);

  @override
  State<GoogleMapBottomSheet> createState() => _GoogleMapBottomSheetState();
}

class _GoogleMapBottomSheetState extends State<GoogleMapBottomSheet> {
  TextEditingController _locationController = TextEditingController();
  Set<Marker> _markers = {};
  GoogleMapController? _mapController;
  double? _currentLatitude;
  double? _currentLongitude;
  bool _isLoading = true; // Add a loading flag
  bool _bottomSheetVisible = true; // Control the visibility of the bottom sheet

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    await _getCurrentLocation();
    // Update the text field with the current location address
    if (_currentLatitude != null && _currentLongitude != null) {
      _updateLocationTextField(_currentLatitude!, _currentLongitude!);
      // Add a marker for the current location
      _addMarker(
        LatLng(_currentLatitude!, _currentLongitude!),
        'Current Location',
      );
    }
    setState(() {
      _isLoading = false; // Set loading flag to false
    });
  }

  Future<void> _getCurrentLocation() async {
    Position? position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (position != null) {
      setState(() {
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      });
    }
  }

  void _updateMarkerFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        _addMarker(
          LatLng(location.latitude, location.longitude),
          'Updated Location',
        );

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
        );
      }
    } catch (e) {
      // Handle geocoding error
      print('Error geocoding: $e');
    }
  }

  void _updateLocationFromAddress(String address) async {
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        // Add a marker for the updated location
        _addMarker(
          LatLng(location.latitude, location.longitude),
          'Updated Location',
        );

        // Update the text field with the new address
        _locationController.text = address;

        // Call the callback function to send location data to the parent widget
        widget.onLocationSelected(
            address, location.latitude, location.longitude);

        _mapController?.animateCamera(
          CameraUpdate.newLatLng(LatLng(location.latitude, location.longitude)),
        );
      }
    } catch (e) {
      // Handle geocoding error
      print('Error geocoding: $e');
    }
  }

  // Helper method to add a marker
  void _addMarker(LatLng position, String title) {
    final MarkerId markerId = MarkerId(position.toString());
    final Marker marker = Marker(
      markerId: markerId,
      position: position,
      infoWindow: InfoWindow(title: title),
    );

    setState(() {
      _markers.clear(); // Clear existing markers
      _markers.add(marker); // Add the new marker
    });
  }

  // Helper method to update the text field with an address based on coordinates
  void _updateLocationTextField(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);

    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks.first;
      String address = placemark.thoroughfare ?? '';
      address +=
          (address.isNotEmpty ? ', ' : '') + (placemark.subLocality ?? '');
      address += (address.isNotEmpty ? ', ' : '') + (placemark.locality ?? '');
      address += (address.isNotEmpty ? ', ' : '') +
          (placemark.administrativeArea ?? '');
      address += (address.isNotEmpty ? ', ' : '') + (placemark.country ?? '');

      _locationController.text = address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible:
          _bottomSheetVisible, // Control the visibility of the bottom sheet
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: TextField(
                  controller: _locationController,
                  decoration: InputDecoration(
                    labelText: 'Enter Address',
                    labelStyle: TextStyle(
                      color: Styles.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.search, color: Styles.primaryColor),
                      onPressed: () {
                        String address = _locationController.text;
                        _updateLocationFromAddress(address);
                      },
                    ),
                  ),
                  onChanged: (String address) {
                    _updateMarkerFromAddress(address);
                  },
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : (_currentLatitude != null && _currentLongitude != null)
                        ? GoogleMap(
                            onMapCreated: (GoogleMapController controller) {
                              setState(() {
                                _mapController = controller;
                              });
                            },
                            initialCameraPosition: CameraPosition(
                              target: LatLng(_currentLatitude ?? 0,
                                  _currentLongitude ?? 0),
                              zoom: 15.0,
                            ),
                            markers: _markers,
                          )
                        : Center(
                            child: Text(
                              'Location not available',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
