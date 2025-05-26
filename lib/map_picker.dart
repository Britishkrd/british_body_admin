import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

class PlacePickerScreen extends StatefulWidget {
  const PlacePickerScreen({super.key});

  @override
  State<PlacePickerScreen> createState() => _PlacePickerScreenState();
}

class _PlacePickerScreenState extends State<PlacePickerScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _placeNameController = TextEditingController();
  LatLng? _selectedPosition;
  final Set<Marker> _markers = {};
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      final querySnapshot = await _firestore.collection('places').get();
      _markers.clear();
      for (var doc in querySnapshot.docs) {
        _markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(doc['lat'], doc['long']),
            infoWindow: InfoWindow(title: doc['name']),
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      _markers.add(
        Marker(
          markerId: const MarkerId('selected'),
          position: position,
          infoWindow: const InfoWindow(title: 'Selected Location'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    });
  }

  void _savePlace() async {
    if (_placeNameController.text.isEmpty || _selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location and enter a name')),
      );
      return;
    }

    try {
      await _firestore.collection('places').add({
        'name': _placeNameController.text,
        'lat': _selectedPosition!.latitude,
        'long': _selectedPosition!.longitude,
      });
      _placeNameController.clear();
      _selectedPosition = null;
      _markers.removeWhere((marker) => marker.markerId.value == 'selected');
      await _fetchPlaces();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Place saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving place: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Places'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: 100.w,
                  height: 6.h,
                  margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                  child: Material1.textfield(
                    hint: 'Place Name',
                    controller: _placeNameController,
                    textColor: Colors.black,
                  ),
                ),
                Container(
                  width: 100.w,
                  height: 6.h,
                  margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                  child: Material1.button(
                    label: 'Save Place',
                    buttoncolor: Material1.primaryColor,
                    textcolor: Colors.white,
                    function: _savePlace,
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      _mapController = controller;
                    },
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(35.583166, 45.426032), // Default to Erbil
                      zoom: 12,
                    ),
                    markers: _markers,
                    onTap: _onMapTap,
                  ),
                ),
              ],
            ),
    );
  }
}