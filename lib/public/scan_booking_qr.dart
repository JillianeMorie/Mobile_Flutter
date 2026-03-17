import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ticketing_flutter/public/booking_confirmation.dart';
import 'package:ticketing_flutter/services/flight.dart';

class ScanBookingQrPage extends StatefulWidget {
  const ScanBookingQrPage({super.key});

  @override
  State<ScanBookingQrPage> createState() => _ScanBookingQrPageState();
}

class _ScanBookingQrPageState extends State<ScanBookingQrPage> {
  bool _isProcessing = false;
  String? _error;

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isProcessing) return;
    if (capture.barcodes.isEmpty) return;

    final rawValue = capture.barcodes.first.rawValue;
    if (rawValue == null || rawValue.isEmpty) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      final decoded = jsonDecode(rawValue) as Map<String, dynamic>;

      final flightJson = decoded['flight'] as Map<String, dynamic>;
      final flight = Flight.fromJson(flightJson);

      final bundle = (decoded['bundle'] as Map).cast<String, dynamic>();
      final guestsList = (decoded['guests'] as List)
          .map((e) => (e as Map).cast<String, dynamic>())
          .toList();
      final seatAssignments = (decoded['seatAssignments'] as List)
          .map((e) => e.toString())
          .toList();

      final selectedPrice =
          (decoded['selectedPrice'] as num?)?.toDouble() ?? 0.0;
      final travelClass = decoded['travelClass'] as String? ?? 'Economy';
      final adults = decoded['adults'] as int? ?? 0;
      final children = decoded['children'] as int? ?? 0;
      final infants = decoded['infants'] as int? ?? 0;
      final paymentMethod = decoded['paymentMethod'] as String?;

      if (!mounted) return;

      // Navigate to the same booking confirmation screen using the scanned data.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => BookingConfirmationPage(
            flight: flight,
            bundle: bundle,
            guests: guestsList,
            seatAssignments: seatAssignments,
            selectedPrice: selectedPrice,
            travelClass: travelClass,
            adults: adults,
            children: children,
            infants: infants,
            paymentMethod: paymentMethod,
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Invalid booking QR code.';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Booking QR'),
      ),
      body: Stack(
        children: [
          MobileScanner(
            fit: BoxFit.cover,
            onDetect: _handleBarcode,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Point the camera at the booking QR code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

