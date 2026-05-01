import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';
import 'package:ticketing_flutter/services/flight.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/public/booking_summary.dart';

class UserBookingDetailsPage extends StatefulWidget {
  final Flight flight;
  final Map<String, dynamic> bundle;
  final int adults;
  final int children;
  final int infants;

  const UserBookingDetailsPage({
    super.key,
    required this.flight,
    required this.bundle,
    required this.adults,
    required this.children,
    required this.infants,
  });

  @override
  State<UserBookingDetailsPage> createState() => _UserBookingDetailsPageState();
}

class _UserBookingDetailsPageState extends State<UserBookingDetailsPage> {
  Map<String, dynamic>? _user;
  double? _selectedPrice;
  String? _selectedClass;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final us = UserService();
    final logged = await us.isLoggedIn();
    if (!logged) return;
    final u = await us.getCurrentUser();
    if (!mounted) return;
    setState(() => _user = u);
  }

  String? readField(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      if (m.containsKey(k) && m[k] != null) return m[k].toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (_selectedPrice == null) {
        final raw = args['selectedPrice'];
        if (raw is double) _selectedPrice = raw;
        if (raw is int) _selectedPrice = raw.toDouble();
      }
      if (_selectedClass == null && args['selectedClass'] != null) {
        _selectedClass = args['selectedClass'] as String;
      }
    }

    final firstName = readField(_user, ['FirstName', 'firstName', 'firstname']);
    final lastName = readField(_user, ['LastName', 'lastName', 'lastname']);
    final phone = readField(_user, ['PhoneNumber', 'phoneNumber', 'phone']);
    final email = readField(_user, ['Email', 'email']);
    final dobRaw = readField(_user, [
      'DateOfBirth',
      'dateOfBirth',
      'dob',
      'birthdate',
    ]);

    return DisableRoutePop(child: Scaffold(
      appBar: AppBar(title: const Text('Your Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${firstName ?? ''} ${lastName ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (email != null) Text('Email: $email'),
                    if (phone != null) Text('Mobile: $phone'),
                    if (dobRaw != null) Text('Date of birth: $dobRaw'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'If the information above is correct, continue to booking.',
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _user == null
                  ? null
                  : () {
                      final guest = {
                        'type': 'Adult',
                        'label': 'Adult 1',
                        'firstName': firstName ?? '',
                        'lastName': lastName ?? '',
                        'dob': dobRaw ?? '',
                        'nationality': _user?['Nationality'] ?? '',
                        'age': null,
                        'title': _user?['Title'],
                        'mobileNumber': phone ?? '',
                        'email': email ?? '',
                      };

                      final guests = [guest];

                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  BookingSummaryPage(
                                    flight: widget.flight,
                                    bundle: widget.bundle,
                                    guests: guests,
                                    selectedPrice:
                                        _selectedPrice ?? widget.flight.price,
                                    selectedClass: _selectedClass,
                                  ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Continue to Summary'),
            ),
          ],
        ),
      ),
    ),
    );
  }
}
