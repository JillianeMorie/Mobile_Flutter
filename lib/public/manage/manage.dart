import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';
import 'package:ticketing_flutter/public/bookpage.dart';
import 'package:ticketing_flutter/public/about.dart';
import 'package:ticketing_flutter/public/explore.dart';
import 'package:ticketing_flutter/public/travel_info.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/user/luggage_map.dart';

class ManagePage extends StatefulWidget {
  const ManagePage({super.key});

  @override
  State<ManagePage> createState() => _ManagePageState();
}

class _ManagePageState extends State<ManagePage> {
  Future<void> _openLuggageTrackerWithInput() async {
    final controller = TextEditingController();
    final trackerId = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Luggage Tracker',
          style: TextStyle(color: Colors.cyanAccent),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Device ID / Tracker Number',
            labelStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.grey[800],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Track'),
          ),
        ],
      ),
    );

    if (!mounted || trackerId == null || trackerId.isEmpty) return;
    _nav(LuggageMapPage(initialTrackerId: trackerId));
  }

  Widget _drawerItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  void _nav(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  void _navReplace(Widget page) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: Duration.zero,
      ),
    );
  }

  void _showCheckInContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Check-In',
          style: TextStyle(color: Colors.amberAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your booking details to check in:',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Booking Reference',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amberAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Check-In'),
          ),
        ],
      ),
    );
  }

  void _showManageBookingContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Manage Booking',
          style: TextStyle(color: Colors.blueAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Reference: ABC123',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Flight Details:',
              style: TextStyle(color: Colors.white70),
            ),
            const Text('From: Manila', style: TextStyle(color: Colors.white)),
            const Text('To: Cebu', style: TextStyle(color: Colors.white)),
            const Text(
              'Date: Dec 25, 2025',
              style: TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            const Text(
              'Status: Confirmed',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showFlightStatusContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Flight Status',
          style: TextStyle(color: Colors.greenAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Flight Number',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[800],
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.greenAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Check Status'),
          ),
        ],
      ),
    );
  }

  void _showAddOnsContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Add-ons',
          style: TextStyle(color: Colors.orangeAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: const Icon(Icons.chair, color: Colors.orangeAccent),
              title: const Text(
                'Seat Selection',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Choose your preferred seat',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.restaurant, color: Colors.orangeAccent),
              title: const Text('Meals', style: TextStyle(color: Colors.white)),
              subtitle: const Text(
                'Pre-order your meals',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.luggage, color: Colors.orangeAccent),
              title: const Text(
                'Baggage',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Add extra baggage allowance',
                style: TextStyle(color: Colors.white70),
              ),
              onTap: () {},
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }

  void _showSpecialAssistanceContent() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text(
          'Special Assistance',
          style: TextStyle(color: Colors.purpleAccent),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Services:',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              title: const Text(
                'Wheelchair Assistance',
                style: TextStyle(color: Colors.white),
              ),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.purpleAccent,
            ),
            CheckboxListTile(
              title: const Text(
                'Medical Equipment',
                style: TextStyle(color: Colors.white),
              ),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.purpleAccent,
            ),
            CheckboxListTile(
              title: const Text(
                'Special Meals',
                style: TextStyle(color: Colors.white),
              ),
              value: false,
              onChanged: (value) {},
              activeColor: Colors.purpleAccent,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purpleAccent,
              foregroundColor: Colors.black,
            ),
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DisableRoutePop(child: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
        ),
      ),
      child: Scaffold(
        drawer: Drawer(
          width: 300,
          backgroundColor: const Color(0xFF111827),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
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
              _drawerItem(
                icon: Icons.flight,
                label: 'Book',
                onTap: () => _navReplace(const FlightBookingApp()),
              ),
              _drawerItem(
                icon: Icons.manage_accounts,
                label: 'Manage',
                onTap: () => _navReplace(const ManagePage()),
              ),
              _drawerItem(
                icon: Icons.info,
                label: 'Travel Info',
                onTap: () => _nav(const TravelInfoPage()),
              ),
              _drawerItem(
                icon: Icons.explore,
                label: 'Explore',
                onTap: () => _nav(const ExplorePage()),
              ),
              _drawerItem(
                icon: Icons.home,
                label: 'About',
                onTap: () => _nav(const About()),
              ),
              _drawerItem(
                icon: Icons.login,
                label: 'Login',
                onTap: () => _nav(const LoginPage()),
              ),
            ],
          ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: MediaQuery.of(context).padding.top + 20,
            bottom: MediaQuery.of(context).padding.bottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Text(
                "Manage Your Trip",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Check in, manage bookings, and more — all in one place.",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              const SizedBox(height: 30),

              // Main options (3 cards)
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 28) / 3;
                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: ManageMainCard(
                            icon: Icons.login_rounded,
                            title: "Check-In",
                            color: Colors.amberAccent,
                            onTap: _showCheckInContent,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: ManageMainCard(
                            icon: Icons.airplane_ticket_rounded,
                            title: "Manage Booking",
                            color: Colors.blueAccent,
                            onTap: _showManageBookingContent,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: ManageMainCard(
                            icon: Icons.flight_takeoff_rounded,
                            title: "Flight Status",
                            color: Colors.greenAccent,
                            onTap: _showFlightStatusContent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 40),

              const Divider(
                color: Colors.white24,
                thickness: 1,
                indent: 10,
                endIndent: 10,
              ),
              const SizedBox(height: 30),

              // Below section
              const Text(
                "Other Services",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = (constraints.maxWidth - 14) / 2;
                  return IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: ManageSubCard(
                            icon: Icons.shopping_bag_rounded,
                            title: "Add-ons",
                            subtitle: "Add seats, meals, and baggage",
                            color: Colors.orangeAccent,
                            onTap: _showAddOnsContent,
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: ManageSubCard(
                            icon: Icons.accessibility_new_rounded,
                            title: "Special Assistance",
                            subtitle: "Request travel support or help",
                            color: Colors.purpleAccent,
                            onTap: _showSpecialAssistanceContent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              ManageSubCard(
                icon: Icons.location_on_rounded,
                title: "Luggage Tracker",
                subtitle: "Enter tracker device ID and track live location",
                color: Colors.cyanAccent,
                onTap: _openLuggageTrackerWithInput,
              ),

              const SizedBox(height: 135),

              // Footer
              Center(
                child: Text(
                  "© 2025 Airlines Ticketing. All rights reserved.",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
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
}

// MAIN option cards (top 3)
class ManageMainCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback? onTap;

  const ManageMainCard({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  State<ManageMainCard> createState() => _ManageMainCardState();
}

class _ManageMainCardState extends State<ManageMainCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 1.05 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(scale),
        curve: Curves.easeOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.color.withOpacity(0.6), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 45, color: widget.color),
            const SizedBox(height: 12),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// BELOW section cards
class ManageSubCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const ManageSubCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  State<ManageSubCard> createState() => _ManageSubCardState();
}

class _ManageSubCardState extends State<ManageSubCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double scale = _pressed ? 1.05 : 1.0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        transform: Matrix4.identity()..scale(scale),
        curve: Curves.easeOut,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: widget.color.withOpacity(0.5), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(widget.icon, size: 40, color: widget.color),
            const SizedBox(height: 14),
            Text(
              widget.title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.subtitle,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
