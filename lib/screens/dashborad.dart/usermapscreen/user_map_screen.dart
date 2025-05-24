import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

// class UsersMapView extends StatefulWidget {
//   const UsersMapView({super.key});

//   @override
//   State<UsersMapView> createState() => _UsersMapViewState();
// }

// class _UsersMapViewState extends State<UsersMapView> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   GoogleMapController? _mapController;
//   final Set<Marker> _markers = {};
//   bool _isLoading = true;
//   bool _isWeb = false;
//   LatLng? _center;

//   @override
//   void initState() {
//     super.initState();
//     _isWeb = kIsWeb;
//     _fetchUsers();
//   }

//   Future<void> _fetchUsers() async {
//     try {
//       final querySnapshot = await _firestore.collection('user').get();

//       if (querySnapshot.docs.isNotEmpty) {
//         // Use first user's location as initial center if available
//         final firstUser = querySnapshot.docs.first;
//         if (firstUser['lat'] != 0 && firstUser['long'] != 0) {
//           _center = LatLng(firstUser['lat'], firstUser['long']);
//         } else {
//           _center = const LatLng(35.583166, 45.426032); // Default to Erbil
//         }

//         // Add markers for all users
//         for (var doc in querySnapshot.docs) {
//           if (doc['lat'] != 0 && doc['long'] != 0) {
//             _markers.add(
//               Marker(
//                 markerId: MarkerId(doc.id),
//                 position: LatLng(doc['lat'], doc['long']),
//                 infoWindow: InfoWindow(
//                   title: doc['name'],
//                   snippet: doc['checkin'] ? 'Checked In' : 'Not Checked In',
//                 ),
//                 icon: doc['checkin']
//                     ? BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueGreen)
//                     : BitmapDescriptor.defaultMarkerWithHue(
//                         BitmapDescriptor.hueRed),
//               ),
//             );
//           }
//         }
//       } else {
//         _center = const LatLng(36.1911, 44.0092); // Default location
//       }

//       setState(() {
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _center = const LatLng(36.1911, 44.0092);
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading users: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('شوێنی کارمەندەکان'),
//         foregroundColor: Colors.white,
//         backgroundColor: Material1.primaryColor,
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _isWeb && _center == null
//               ? const Center(
//                   child: Text(
//                       'Google Maps not available on web without proper setup'))
//               : GoogleMap(
//                   onMapCreated: (controller) {
//                     _mapController = controller;
//                   },
//                   initialCameraPosition: CameraPosition(
//                     target: _center ?? const LatLng(36.1911, 44.0092),
//                     zoom: 12,
//                   ),
//                   markers: _markers,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: true,
//                 ),
//       // floatingActionButton: FloatingActionButton(
//       //   backgroundColor: Material1.primaryColor,
//       //   child: const Icon(Icons.refresh, color: Colors.white),
//       //   onPressed: () {
//       //     setState(() {
//       //       _isLoading = true;
//       //       _markers.clear();
//       //     });
//       //     _fetchUsers();
//       //   },
//       // ),
//     );
//   }
// }

class UsersMapView extends StatefulWidget {
  const UsersMapView({super.key});

  @override
  State<UsersMapView> createState() => _UsersMapViewState();
}

class _UsersMapViewState extends State<UsersMapView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _isWeb = false;
  LatLng? _center;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isWeb = kIsWeb;
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    if (!_isWeb) {
      final status = await Permission.location.request();
      if (status.isDenied) {
        setState(() {
          _errorMessage = 'Location permission required to view the map';
          _isLoading = false;
        });
        return;
      }
    }
    await _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      final querySnapshot = await _firestore.collection('user').get();

      if (querySnapshot.docs.isNotEmpty) {
        // Use first user's location as initial center if available
        final firstUser = querySnapshot.docs.first;
        if (firstUser['lat'] != 0 && firstUser['long'] != 0) {
          _center = LatLng(firstUser['lat'], firstUser['long']);
        } else {
          _center = const LatLng(35.583166, 45.426032); // Default to Erbil
        }

        // Add markers for all users
        for (var doc in querySnapshot.docs) {
          if (doc['lat'] != 0 && doc['long'] != 0) {
            _markers.add(
              Marker(
                markerId: MarkerId(doc.id),
                position: LatLng(doc['lat'], doc['long']),
                infoWindow: InfoWindow(
                  title: doc['name'],
                  snippet: doc['checkin'] ? 'Checked In' : 'Not Checked In',
                ),
                icon: doc['checkin']
                    ? BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen)
                    : BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
              ),
            );
          }
        }
      } else {
        _center = const LatLng(36.1911, 44.0092); // Default location
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading map data: ${e.toString()}';
        _center = const LatLng(36.1911, 44.0092);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('شوێنی کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _center == null
                  ? const Center(child: Text('No location data available'))
                  : GoogleMap(
                      onMapCreated: (controller) {
                        _mapController = controller;
                      },
                      initialCameraPosition: CameraPosition(
                        target: _center!,
                        zoom: 12,
                      ),
                      markers: _markers,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      onCameraMoveStarted: () => debugPrint('Map started moving'),
                      onCameraIdle: () => debugPrint('Map idle'),
                    ),
    );
  }
}