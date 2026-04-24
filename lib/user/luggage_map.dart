// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class LuggageMapPage extends StatelessWidget {
//   final double lat;
//   final double lng;
//   final String status;

//   const LuggageMapPage({super.key, required this.lat, required this.lng, required this.status});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Live Location")),
//       body: GoogleMap(
//         initialCameraPosition: CameraPosition(target: LatLng(lat, lng), zoom: 14),
//         markers: {
//           Marker(markerId: const MarkerId('luggage'), position: LatLng(lat, lng), infoWindow: InfoWindow(title: status)),
//         },
//       ),
//     );
//   }
// }
