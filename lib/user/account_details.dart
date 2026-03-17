import 'package:flutter/material.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/services/user_service.dart';

class MyAccountDetailsPage extends StatefulWidget {
  const MyAccountDetailsPage({super.key});

  @override
  State<MyAccountDetailsPage> createState() => _MyAccountDetailsPageState();
}

class _MyAccountDetailsPageState extends State<MyAccountDetailsPage> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final userService = UserService();
    final loggedIn = await userService.isLoggedIn();
    if (!loggedIn) {
      if (mounted) {
        setState(() {
          _error = 'You are not logged in. Please login again.';
          _isLoading = false;
        });
      }
      return;
    }

    final user = await userService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  String? _readField(List<String> keys) {
    if (_user == null) return null;
    for (final key in keys) {
      if (_user!.containsKey(key) && _user![key] != null) {
        return _user![key].toString();
      }
    }
    return null;
  }

  Future<void> _logout() async {
    final service = UserService();
    await service.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName = _readField(['FirstName', 'firstName', 'firstname']);
    final lastName = _readField(['LastName', 'lastName', 'lastname']);
    final email = _readField(['Email', 'email']);
    final phone = _readField(['PhoneNumber', 'phoneNumber', 'phone']);
    final dob = _readField(['DateOfBirth', 'dateOfBirth', 'dob', 'birthdate']);
    final gender = _readField(['Gender', 'gender']);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
        backgroundColor: const Color(0xFF111827),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: const Text('Login'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your profile',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (firstName != null || lastName != null)
                            _buildInfoItem(
                              'Name',
                              '${firstName ?? ''} ${lastName ?? ''}'.trim(),
                            ),
                          if (email != null) _buildInfoItem('Email', email),
                          if (phone != null) _buildInfoItem('Phone', phone),
                          if (dob != null) _buildInfoItem('Birthdate', dob),
                          if (gender != null) _buildInfoItem('Gender', gender),
                          if (_user != null &&
                              _user!.containsKey('Nationality'))
                            _buildInfoItem(
                              'Nationality',
                              _user!['Nationality']?.toString() ?? '',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                      ),
                      onPressed: _logout,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                        child: Text('Logout'),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
