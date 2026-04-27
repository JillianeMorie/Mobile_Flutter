import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ticketing_flutter/public/home.dart';
import 'package:ticketing_flutter/user/user_booking_confirmation.dart';
import 'package:ticketing_flutter/services/flight.dart';
import 'dart:convert';

class UserPaymentPage extends StatefulWidget {
  const UserPaymentPage({super.key});

  @override
  State<UserPaymentPage> createState() => _UserPaymentPageState();
}

class _UserPaymentPageState extends State<UserPaymentPage> {
  String? _method; // 'cash' | 'maya' | 'card'
  final _cardName = TextEditingController();
  final _cardNumber = TextEditingController();
  final _cardExpiry = TextEditingController();
  final _cardCvv = TextEditingController();

  @override
  void dispose() {
    _cardName.dispose();
    _cardNumber.dispose();
    _cardExpiry.dispose();
    _cardCvv.dispose();
    super.dispose();
  }

  bool get _isCardValid {
    return _cardName.text.trim().isNotEmpty &&
        _cardNumber.text.trim().length >= 12 &&
        _cardExpiry.text.trim().isNotEmpty &&
        _cardCvv.text.trim().length >= 3;
  }

  Future<void> _saveBookingHistory({
    required Flight flight,
    required Map<String, dynamic> bundle,
    required List<Map<String, dynamic>> guests,
    required List<String> seatAssignments,
    required double selectedPrice,
    required String travelClass,
    required int adults,
    required int children,
    required int infants,
    required String paymentMethod,
    required double total,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    const key = 'user_booking_history';
    final raw = prefs.getString(key);
    final List<dynamic> existing = raw == null ? [] : jsonDecode(raw) as List<dynamic>;

    final bookingEntry = <String, dynamic>{
      'bookingRef': DateTime.now().millisecondsSinceEpoch.toString().substring(7),
      'airline': flight.airline,
      'flightNumber': flight.flightNumber,
      'from': flight.from,
      'to': flight.to,
      'date': flight.date,
      'time': flight.time,
      'travelClass': travelClass,
      'bundle': bundle['name']?.toString() ?? '',
      'guestsCount': guests.length,
      'adults': adults,
      'children': children,
      'infants': infants,
      'seatAssignments': seatAssignments,
      'selectedPrice': selectedPrice,
      'total': total,
      'paymentMethod': paymentMethod,
      'bookedAt': DateTime.now().toIso8601String(),
    };

    existing.insert(0, bookingEntry);
    await prefs.setString(key, jsonEncode(existing));
  }

  @override
  Widget build(BuildContext context) {
    // Get all booking data passed from booking summary
    final args = ModalRoute.of(context)?.settings.arguments;
    final double? total = (args is Map && args['total'] is num)
        ? (args['total'] as num).toDouble()
        : null;
    final totalLabel = total != null ? "PHP ${total.toStringAsFixed(2)}" : "--";

    // Extract booking data for confirmation page
    final Flight? flight = (args is Map && args['flight'] is Flight)
        ? args['flight'] as Flight
        : null;
    final Map<String, dynamic>? bundle = (args is Map && args['bundle'] is Map)
        ? Map<String, dynamic>.from(args['bundle'] as Map)
        : null;
    final List<Map<String, dynamic>>? guests =
        (args is Map && args['guests'] is List)
        ? (args['guests'] as List)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList()
        : null;
    final List<String>? seatAssignments =
        (args is Map && args['seatAssignments'] is List)
        ? List<String>.from(args['seatAssignments'] as List)
        : null;
    final double? selectedPrice = (args is Map && args['selectedPrice'] is num)
        ? (args['selectedPrice'] as num).toDouble()
        : null;
    final String? travelClass = (args is Map && args['travelClass'] is String)
        ? args['travelClass'] as String
        : null;
    final int? adults = (args is Map && args['adults'] is int)
        ? args['adults'] as int
        : null;
    final int? children = (args is Map && args['children'] is int)
        ? args['children'] as int
        : null;
    final int? infants = (args is Map && args['infants'] is int)
        ? args['infants'] as int
        : null;

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
                  "Payment",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Total summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Total",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      Text(
                        totalLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Choose Payment Method",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 8),

                // Cash
                RadioListTile<String>(
                  value: 'cash',
                  groupValue: _method,
                  title: const Text(
                    "Cash",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Pay at counter or on arrival",
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _method = v),
                ),

                // Maya
                RadioListTile<String>(
                  value: 'maya',
                  groupValue: _method,
                  title: const Text(
                    "Maya",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Pay via Maya QR or wallet",
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _method = v),
                ),

                // Debit/Credit Card
                RadioListTile<String>(
                  value: 'card',
                  groupValue: _method,
                  title: const Text(
                    "Debit / Credit Card",
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: const Text(
                    "Pay with card",
                    style: TextStyle(color: Colors.white54),
                  ),
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => _method = v),
                ),

                // Card fields (only when card selected)
                if (_method == 'card') ...[
                  const SizedBox(height: 8),
                  _buildField(controller: _cardName, hint: "Cardholder Name"),
                  const SizedBox(height: 8),
                  _buildField(
                    controller: _cardNumber,
                    hint: "Card Number",
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildField(
                          controller: _cardExpiry,
                          hint: "MM/YY",
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 100,
                        child: _buildField(
                          controller: _cardCvv,
                          hint: "CVV",
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed:
                        (_method == null ||
                            (_method == 'card' && !_isCardValid))
                        ? null
                        : () async {
                            // Show a short "Processing payment…" dialog
                            await showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: const Color(0xFF111827),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                content: const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      "Processing payment...",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ),
                            );

                            // Simulate payment processing
                            await Future.delayed(const Duration(seconds: 1));
                            Navigator.pop(context); // Close loading dialog

                            // Navigate to confirmation page if all data is available
                            if (flight != null &&
                                bundle != null &&
                                guests != null &&
                                seatAssignments != null &&
                                selectedPrice != null &&
                                travelClass != null &&
                                adults != null &&
                                children != null &&
                                infants != null) {
                              final methodLabel = _method == 'cash'
                                  ? 'Cash'
                                  : _method == 'maya'
                                  ? 'Maya'
                                  : 'Debit/Credit Card';
                              final totalAmount = total ??
                                  (selectedPrice +
                                      (((bundle['price'] ?? 0) as num).toDouble() *
                                          guests.length));
                              await _saveBookingHistory(
                                flight: flight,
                                bundle: bundle,
                                guests: guests,
                                seatAssignments: seatAssignments,
                                selectedPrice: selectedPrice,
                                travelClass: travelClass,
                                adults: adults,
                                children: children,
                                infants: infants,
                                paymentMethod: methodLabel,
                                total: totalAmount,
                              );
                              Navigator.pushReplacement(
                                context,
                                PageRouteBuilder(
                                  pageBuilder:
                                      (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) => UserBookingConfirmationPage(
                                        flight: flight,
                                        bundle: bundle,
                                        guests: guests,
                                        seatAssignments: seatAssignments,
                                        selectedPrice: selectedPrice,
                                        travelClass: travelClass,
                                        adults: adults,
                                        children: children,
                                        infants: infants,
                                        paymentMethod: methodLabel,
                                      ),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                ),
                              );
                            } else {
                              // Fallback if data is missing
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => const Home()),
                                (route) => false,
                              );
                            }
                          },
                    child: Text(
                      _method == null
                          ? "Select payment method"
                          : (_method == 'card' ? "Pay with Card" : "Proceed"),
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.blueAccent),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }
}
