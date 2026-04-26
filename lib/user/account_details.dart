import 'package:flutter/material.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/services/user_service.dart';
import 'package:ticketing_flutter/public/search_flight.dart';
import 'package:ticketing_flutter/public/manage/manage.dart';
import 'package:ticketing_flutter/public/travel_info.dart';
import 'package:ticketing_flutter/public/explore.dart';
import 'package:ticketing_flutter/user/userabout.dart';
import 'package:ticketing_flutter/user/userbook_oneway.dart';
import 'package:ticketing_flutter/public/bookpage.dart';

class MyAccountDetailsPage extends StatefulWidget {
  const MyAccountDetailsPage({super.key});

  @override
  State<MyAccountDetailsPage> createState() => _MyAccountDetailsPageState();
}

class _MyAccountDetailsPageState extends State<MyAccountDetailsPage> {
  Map<String, dynamic>? _user;
  bool _isLoading = true;
  String? _error;

  final TextEditingController _tagController = TextEditingController();
  String? _luggageStatus;
  bool _isSearchingLuggage = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
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

  void _trackLuggage() {
    if (_tagController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a baggage tag number'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() => _isSearchingLuggage = true);

    // Replace this with your real API call
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isSearchingLuggage = false;
        _luggageStatus = 'Loaded on flight PR582 at MNL - 2:45 PM';
      });
    });
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A8A),
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuggageTracker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.luggage, color: Color(0xFF1E3A8A)),
              SizedBox(width: 8),
              Text(
                'Luggage Tracker',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _tagController,
            decoration: InputDecoration(
              hintText: 'Enter baggage tag number',
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 23, 37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isSearchingLuggage ? null : _trackLuggage,
              child: _isSearchingLuggage
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Track',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
          if (_luggageStatus != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _luggageStatus!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContent({
    required String? fullName,
    required String? email,
    required String? phone,
    required String? dob,
    required String? gender,
  }) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _error!,
              style: const TextStyle(color: Colors.white),
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
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 16),
                if (fullName != null) _buildInfoItem('Name', fullName),
                if (email != null) _buildInfoItem('Email', email),
                if (phone != null) _buildInfoItem('Phone', phone),
                if (dob != null) _buildInfoItem('Birthdate', dob),
                if (gender != null) _buildInfoItem('Gender', gender),
                if (_user != null && _user!.containsKey('Nationality'))
                  _buildInfoItem(
                    'Nationality',
                    _user!['Nationality']?.toString() ?? '',
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildLuggageTracker(),
          const SizedBox(height: 24),
          SizedBox(
            height: 56,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 5, 23, 37),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
              child: const Text(
                'Logout',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = _readField(['FullName', 'fullName', 'fullname']);
    final email = _readField(['Email', 'email']);
    final phone = _readField(['PhoneNumber', 'phone']);
    var dob = _readField(['DateOfBirth', 'dateOfBirth', 'dob', 'birthdate']);
    if (dob != null && dob.contains('T')) {
      dob = dob.split('T')[0];
    }
    final gender = _readField(['Gender', 'gender']);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        width: 300.0,
        backgroundColor: const Color(0xFF111827),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: const DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF000000),
                      Color(0xFF111827),
                      Color(0xFF1E3A8A),
                    ],
                  ),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flight, color: Colors.white),
              title: const Text('Book', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const FlightBookingApp(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.manage_accounts, color: Colors.white),
              title: const Text(
                'Manage',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const ManagePage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: Colors.white),
              title: const Text(
                'Travel Info',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const TravelInfoPage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.explore, color: Colors.white),
              title: const Text(
                'Explore',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const ExplorePage(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('About', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        const Userabout(),
                    transitionDuration: Duration.zero,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle, color: Colors.white),
              title: const Text(
                'My Account',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF000000),
                        Color(0xFF111827),
                        Color(0xFF1E3A8A),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue.shade100,
                  width: double.infinity,
                ),
              ),
            ],
          ),
          Positioned(
            top: 30,
            left: 10,
            child: Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.menu, color: Colors.white, size: 30),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: _buildContent(
                fullName: fullName,
                email: email,
                phone: phone,
                dob: dob,
                gender: gender,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
