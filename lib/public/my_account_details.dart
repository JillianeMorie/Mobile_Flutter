import 'package:flutter/material.dart';
import 'package:ticketing_flutter/services/user_service.dart';

class MyAccountDetailsPage extends StatefulWidget {
  const MyAccountDetailsPage({super.key});

  @override
  State<MyAccountDetailsPage> createState() => _MyAccountDetailsPageState();
}

class _MyAccountDetailsPageState extends State<MyAccountDetailsPage> {
  late final Future<Map<String, dynamic>?> _userFuture =
      UserService().getCurrentUser();

  String? _readField(Map<String, dynamic>? m, List<String> keys) {
    if (m == null) return null;
    for (final k in keys) {
      final v = m[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return null;
  }

  Widget _row(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('My Account Details'),
      ),
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
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Map<String, dynamic>?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Failed to load account details.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }

                final user = snapshot.data;
                if (user == null) {
                  return const Center(
                    child: Text(
                      'No user details found. Please login again.',
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final firstName =
                    _readField(user, ['FirstName', 'firstName', 'firstname']);
                final middleName =
                    _readField(user, ['MiddleName', 'middleName', 'middlename']);
                final lastName =
                    _readField(user, ['LastName', 'lastName', 'lastname']);
                final email = _readField(user, ['Email', 'email']);
                final phone = _readField(user, [
                  'PhoneNumber',
                  'phoneNumber',
                  'contactNumber',
                  'phone',
                ]);
                final dob = _readField(user, [
                  'DateOfBirth',
                  'dateOfBirth',
                  'birthdate',
                  'dob',
                ]);
                final gender = _readField(user, ['Gender', 'gender']);

                return SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _row('First name', firstName),
                        _row('Middle name', middleName),
                        _row('Last name', lastName),
                        _row('Email', email),
                        _row('Contact number', phone),
                        _row('Birthdate', dob),
                        _row('Gender', gender),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

