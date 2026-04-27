import 'dart:math';
import 'package:flutter/material.dart';
import 'package:ticketing_flutter/user/userpayment.dart';
import 'package:ticketing_flutter/services/flight.dart';

class UserBookingSummaryPage extends StatelessWidget {
  final Flight flight;
  final Map<String, dynamic> bundle;
  final List<Map<String, dynamic>> guests;
  final List<String> seatAssignments;
  final double selectedPrice;
  final String travelClass;

  UserBookingSummaryPage({
    super.key,
    required this.flight,
    required this.bundle,
    required this.guests,
    double? selectedPrice,
    String? selectedClass,
  }) : travelClass = selectedClass ?? 'Economy', // Only default if not provided
       selectedPrice = selectedPrice ?? flight.price,
       seatAssignments = _generateSeats(guests.length);

  // ------------------------------------------------------------
  // Seat generation (unchanged)
  // ------------------------------------------------------------
  static List<String> _generateSeats(int count) {
    if (count == 0) return [];
    const seatLetters = ["A", "B", "C", "D", "E", "F"];
    final random = Random();
    final seats = <String>[];

    while (seats.length < count) {
      final row = random.nextInt(40) + 1;
      final letter = seatLetters[random.nextInt(seatLetters.length)];
      final seat = "$row$letter";

      if (!seats.contains(seat)) seats.add(seat);
    }
    return seats;
  }

  // ------------------------------------------------------------
  // Helpers for totals & formatting (unchanged)
  // ------------------------------------------------------------
  int get travelerCount => guests.length;
  double get bundlePerGuest => (bundle["price"] ?? 0).toDouble();

  // selectedPrice is already the total flight fare from booking page
  double get totalFlight => selectedPrice;
  double get totalBundle => bundlePerGuest * travelerCount;
  double get grandTotal => totalFlight + totalBundle;

  String currency(double v) => "PHP ${v.toStringAsFixed(2)}";

  // ------------------------------------------------------------
  // UI – shared card wrapper (matches PaymentPage)
  // ------------------------------------------------------------
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

  // ------------------------------------------------------------
  // UI – detail row (icon + label)
  // ------------------------------------------------------------
  Widget _detail(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white70),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "$label: $value",
              style: const TextStyle(color: Colors.white70, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UI – city label
  // ------------------------------------------------------------
  Widget _cityText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  // ------------------------------------------------------------
  // UI – fare row
  // ------------------------------------------------------------
  Widget _fareRow(
    String label,
    String price, {
    bool bold = false,
    bool blue = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: blue ? Colors.blueAccent.shade400 : Colors.white,
              fontSize: 16,
              fontWeight: bold ? FontWeight.w900 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UI – info row (label: value)
  // ------------------------------------------------------------
  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(
          "$label: ",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Flight card (re‑styled)
  // ------------------------------------------------------------
  Widget _flightCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              _cityText(flight.from),
              const SizedBox(height: 5),
              const Icon(Icons.flight_takeoff, color: Colors.white, size: 38),
              const SizedBox(height: 5),
              _cityText(flight.to),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _detail(Icons.airlines, "Airline", flight.airline),
        _detail(Icons.numbers, "Flight No.", flight.flightNumber),
        _detail(Icons.calendar_month, "Date", flight.date),
        _detail(Icons.schedule, "Departure", flight.time),
        _detail(Icons.event_seat, "Class", travelClass),
        const SizedBox(height: 15),
        _infoRow("Bundle", bundle["name"]),
        const SizedBox(height: 15),
        const Text(
          "Seat Assignments",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        ...guests.asMap().entries.map((entry) {
          final idx = entry.key;
          final g = entry.value;
          final seat = seatAssignments[idx];

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.event_seat, color: Colors.white70, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "${g["title"] ?? ""} ${g["firstName"]} ${g["lastName"]}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  seat,
                  style: const TextStyle(
                    color: Colors.blueAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ------------------------------------------------------------
  // Fare summary card (re‑styled)
  // ------------------------------------------------------------
  Widget _fareCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Fare Summary",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        _fareRow("Flight Fare", currency(totalFlight)),
        _fareRow(
          "${bundle["name"]} (${travelerCount} pax)",
          bundlePerGuest == 0 ? "Included" : currency(totalBundle),
        ),
        const SizedBox(height: 15),
        const Divider(color: Colors.white24),
        const SizedBox(height: 10),
        _fareRow("TOTAL", currency(grandTotal), bold: true, blue: true),
      ],
    );
  }

  // ------------------------------------------------------------
  // Confirmation + Continue button (re‑styled)
  // ------------------------------------------------------------
  Widget _confirmCard(BuildContext context) {
    return Column(
      children: [
        Row(
          children: const [
            Icon(Icons.check_circle_outline, color: Colors.white70),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                "By tapping Continue, you agree to the airline conditions of carriage.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 4,
              shadowColor: Colors.black38,
            ),
            onPressed: () {
              // Calculate passenger counts from guests
              int adultsCount = 0;
              int childrenCount = 0;
              int infantsCount = 0;
              for (var guest in guests) {
                final type = guest["type"]?.toString().toLowerCase() ?? "";
                if (type == "adult")
                  adultsCount++;
                else if (type == "child")
                  childrenCount++;
                else if (type == "infant")
                  infantsCount++;
              }

              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const UserPaymentPage(),
                  settings: RouteSettings(
                    arguments: {
                      'total': grandTotal,
                      'flight': flight,
                      'bundle': bundle,
                      'guests': guests,
                      'seatAssignments': seatAssignments,
                      'selectedPrice': selectedPrice,
                      'travelClass': travelClass,
                      'adults': adultsCount,
                      'children': childrenCount,
                      'infants': infantsCount,
                    },
                  ),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: const Text(
              "Continue",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // Build method – main scaffold (matches PaymentPage)
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
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
                const Text(
                  "Booking Summary",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Expanded(
                  child: ListView(
                    children: [
                      _card(_flightCard()),
                      const SizedBox(height: 20),
                      _card(_fareCard()),
                      const SizedBox(height: 20),
                      _card(_confirmCard(context)),
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
