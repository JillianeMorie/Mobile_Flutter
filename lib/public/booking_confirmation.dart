import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:ticketing_flutter/services/flight.dart';
import 'package:ticketing_flutter/public/home.dart';
import 'package:ticketing_flutter/auth/register.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Flight flight;
  final Map<String, dynamic> bundle;
  final List<Map<String, dynamic>> guests;
  final List<String> seatAssignments;
  final double selectedPrice;
  final String travelClass;
  final int adults;
  final int children;
  final int infants;
  final String? paymentMethod;

  const BookingConfirmationPage({
    super.key,
    required this.flight,
    required this.bundle,
    required this.guests,
    required this.seatAssignments,
    required this.selectedPrice,
    required this.travelClass,
    required this.adults,
    required this.children,
    required this.infants,
    this.paymentMethod,
  });

  int get travelerCount => guests.length;
  double get bundlePerGuest => (bundle["price"] ?? 0).toDouble();
  double get totalFlight => selectedPrice;
  double get totalBundle => bundlePerGuest * travelerCount;
  double get grandTotal => totalFlight + totalBundle;

  String currency(double v) => "PHP ${v.toStringAsFixed(2)}";

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              "$label:",
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _priceRow(String label, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: isTotal ? Colors.blueAccent.shade400 : Colors.white,
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Generate a stable booking reference for this screen build
    final bookingRef = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);

    // Encode all important booking data into the QR so it can be scanned
    // inside the app and reconstructed into a confirmation screen.
    final qrData = jsonEncode({
      'bookingRef': bookingRef,
      'flight': flight.toJson(),
      'bundle': bundle,
      'guests': guests,
      'seatAssignments': seatAssignments,
      'selectedPrice': selectedPrice,
      'travelClass': travelClass,
      'adults': adults,
      'children': children,
      'infants': infants,
      'paymentMethod': paymentMethod,
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header with success icon
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Booking Confirmed!",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Booking Reference: $bookingRef",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Scrollable content
                Expanded(
                  child: ListView(
                    children: [
                      // Flight Information
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Flight Information"),
                            Center(
                              child: Column(
                                children: [
                                  Text(
                                    flight.from,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Icon(
                                    Icons.flight_takeoff,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    flight.to,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            _infoRow("Airline", flight.airline),
                            _infoRow("Flight Number", flight.flightNumber),
                            _infoRow("Departure Date", flight.date),
                            _infoRow("Departure Time", flight.time),
                            _infoRow("Travel Class", travelClass),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Passenger Information
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Passenger Information"),
                            _infoRow("Adults", adults.toString()),
                            _infoRow("Children", children.toString()),
                            _infoRow("Infants", infants.toString()),
                            _infoRow(
                              "Total Passengers",
                              travelerCount.toString(),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 12),
                            ...guests.asMap().entries.map((entry) {
                              final idx = entry.key;
                              final guest = entry.value;
                              final seat = seatAssignments[idx];
                              final title =
                                  guest["title"] ?? guest["type"] ?? "";
                              final firstName = guest["firstName"] ?? "";
                              final lastName = guest["lastName"] ?? "";
                              final fullName = "$title $firstName $lastName"
                                  .trim();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.event_seat,
                                          color: Colors.blueAccent,
                                          size: 18,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Seat: $seat",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (guest["dob"] != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        "DOB: ${guest["dob"]}",
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Bundle Information
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Bundle Choice"),
                            _infoRow("Bundle", bundle["name"]),
                            if (bundlePerGuest > 0)
                              _infoRow(
                                "Price per Guest",
                                currency(bundlePerGuest),
                              )
                            else
                              const Text(
                                "Included in base fare",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            if (bundle["details"] != null) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 8),
                              const Text(
                                "Bundle Details:",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...(bundle["details"] as List).map<Widget>(
                                (detail) => Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 6,
                                    left: 8,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_outline,
                                        color: Colors.blueAccent,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          detail.toString(),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Payment Summary
                      _card(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionTitle("Payment Summary"),
                            _priceRow("Flight Fare", currency(totalFlight)),
                            _priceRow(
                              "${bundle["name"]} (${travelerCount} pax)",
                              bundlePerGuest == 0
                                  ? "Included"
                                  : currency(totalBundle),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            _priceRow(
                              "TOTAL",
                              currency(grandTotal),
                              isTotal: true,
                            ),
                            if (paymentMethod != null) ...[
                              const SizedBox(height: 12),
                              const Divider(color: Colors.white24),
                              const SizedBox(height: 8),
                              _infoRow("Payment Method", paymentMethod!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Buttons
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent.shade400,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => const Home()),
                              (route) => false,
                            );
                          },
                          child: const Text(
                            "Back to Home",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Generate QR code button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.blueAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  "Boarding QR Code",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                content: SizedBox(
                                  width: 260,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 220,
                                        height: 220,
                                        child: QrImageView(
                                          data: qrData,
                                          version: QrVersions.auto,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Booking Ref: $bookingRef",
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Show this QR code at the airport for faster check‑in.",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text("Close"),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.qr_code_2,
                            color: Colors.blueAccent,
                          ),
                          label: const Text(
                            "Generate QR Code",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Create an account now!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blueAccent,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
