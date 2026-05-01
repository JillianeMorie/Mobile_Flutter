import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Map tiles from OpenStreetMap (no Google API key required).
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

  bool get _coordsValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180;

  @override
  Widget build(BuildContext context) {
    if (!_coordsValid) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tracker Location'),
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Invalid coordinates — wait for a GPS fix from the tracker, then open the map again.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final point = LatLng(latitude, longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tracker Location'),
        leading: IconButton(
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: Column(
        children: [
          if (statusText != null && statusText!.isNotEmpty)
            Material(
              color: Colors.blueGrey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(statusText!, style: const TextStyle(fontSize: 13)),
              ),
            ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ticketing_flutter',
                  maxNativeZoom: 19,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 48,
                      height: 48,
                      alignment: Alignment.bottomCenter,
                      child: Icon(
                        Icons.location_pin,
                        size: 48,
                        color: Colors.red.shade700,
                        shadows: const [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black26,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SimpleAttributionWidget(
                  source: const Text('OpenStreetMap contributors'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
