import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserTrackerMapPage extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String? statusText;

  const UserTrackerMapPage({
    super.key,
    required this.latitude,
    required this.longitude,
    this.statusText,
  });

  @override
  Widget build(BuildContext context) {
    final position = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(title: const Text('Tracker Location')),
      body: Column(
        children: [
          if (statusText != null && statusText!.isNotEmpty)
            Container(
              width: double.infinity,
              color: Colors.blueGrey.shade50,
              padding: const EdgeInsets.all(12),
              child: Text(
                statusText!,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: position, zoom: 15),
              markers: {
                Marker(
                  markerId: const MarkerId('tracker_location'),
                  position: position,
                  infoWindow: const InfoWindow(title: 'Tracker location'),
                ),
              },
              myLocationButtonEnabled: false,
              zoomControlsEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}
