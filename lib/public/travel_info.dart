import 'package:flutter/material.dart';
import 'package:ticketing_flutter/public/bookpage.dart';
import 'package:ticketing_flutter/public/about.dart';
import 'package:ticketing_flutter/public/explore.dart';
import 'package:ticketing_flutter/public/manage/manage.dart';
import 'package:ticketing_flutter/auth/login.dart';

class TravelInfoPage extends StatefulWidget {
  const TravelInfoPage({super.key});

  @override
  State<TravelInfoPage> createState() => _TravelInfoPageState();
}

class _TravelInfoPageState extends State<TravelInfoPage> {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
                onTap: () => _nav(const ManagePage()),
              ),
              _drawerItem(
                icon: Icons.info,
                label: 'Travel Info',
                onTap: () => _navReplace(const TravelInfoPage()),
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Travel Information',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your complete guide for flights, policies, and travel reminders.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
                const SizedBox(height: 25),
                _buildCheckInSection(),
                _buildBaggageSection(),
                _buildBookingSection(),
                _buildPaymentSection(),
                _buildTravelAdvisoriesSection(),
                _buildAirplanePoliciesSection(),
                const SizedBox(height: 40),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Builders ---
  Widget _buildCheckInSection() {
    return const _CustomExpansionTile(
      icon: Icons.person_pin_circle,
      title: 'Check-in and Boarding Guidelines',
      children: [
        _InfoItem(
          icon: Icons.devices_other,
          title: 'Online Check-in (Recommended)',
          details:
              'Available from **72 hours up to 2 hours** (International) or **1 hour** (Domestic) before departure. Print or save your mobile boarding pass.',
        ),
        _InfoItem(
          icon: Icons.access_time,
          title: 'Counter Closure Times',
          details:
              '**Domestic Flights:** Counters close **45 minutes** before departure.\n**International Flights:** Close **1 hour** before departure.',
        ),
        _InfoItem(
          icon: Icons.security,
          title: 'Gate & Boarding',
          details:
              'Be at your boarding gate at least **45 minutes** before departure. Gates close promptly!',
        ),
      ],
    );
  }

  Widget _buildBaggageSection() {
    return const _CustomExpansionTile(
      icon: Icons.luggage,
      title: 'Baggage Information',
      children: [
        _InfoItem(
          icon: Icons.backpack,
          title: 'Carry-On Allowance',
          details:
              'One (1) carry-on bag (max **7kg**) plus one small personal item (fits under seat).',
        ),
        _InfoItem(
          icon: Icons.shopping_bag,
          title: 'Checked Baggage',
          details:
              'Pre-purchase baggage allowance online. Max **32kg** per piece. Oversized items incur fees.',
        ),
        _InfoItem(
          icon: Icons.sports_soccer,
          title: 'Special Baggage',
          details:
              'Sports gear and instruments are accepted as checked baggage with applicable fees.',
        ),
      ],
    );
  }

  Widget _buildBookingSection() {
    return const _CustomExpansionTile(
      icon: Icons.book_online,
      title: 'Booking and Rebooking',
      children: [
        _InfoItem(
          icon: Icons.update,
          title: 'Manage Booking',
          details:
              'Add or upgrade baggage, seats, and meals up to **2 hours** before departure.',
        ),
        _InfoItem(
          icon: Icons.payments,
          title: 'Payment Options',
          details:
              'We accept cards, payment centers, and Travel Fund credits for bookings.',
        ),
        _InfoItem(
          icon: Icons.family_restroom,
          title: 'Traveling with Infants/Children',
          details:
              'Infants without seats are free but have no baggage allowance. Strollers can be checked for free.',
        ),
      ],
    );
  }

  Widget _buildPaymentSection() {
    return const _CustomExpansionTile(
      icon: Icons.payment,
      title: 'Payment Options',
      children: [
        _InfoItem(
          icon: Icons.credit_card,
          title: 'Credit/Debit Cards',
          details:
              'Visa, Mastercard, and AmEx accepted. Secure payment processing.',
        ),
        _InfoItem(
          icon: Icons.account_balance_wallet,
          title: 'Travel Fund',
          details:
              'Use credits from previous bookings stored in your Travel Fund account.',
        ),
        _InfoItem(
          icon: Icons.store,
          title: 'Payment Centers',
          details:
              'Pay through authorized banks, remittance, or convenience stores.',
        ),
      ],
    );
  }

  Widget _buildTravelAdvisoriesSection() {
    return const _CustomExpansionTile(
      icon: Icons.warning,
      title: 'Travel Advisories',
      children: [
        _InfoItem(
          icon: Icons.flight_takeoff,
          title: 'Entry Requirements',
          details:
              'Check visa, vaccination, and health requirements before traveling.',
        ),
        _InfoItem(
          icon: Icons.health_and_safety,
          title: 'Health and Safety',
          details:
              'Stay updated on safety protocols and destination-specific guidelines.',
        ),
      ],
    );
  }

  Widget _buildAirplanePoliciesSection() {
    return const _CustomExpansionTile(
      icon: Icons.flight,
      title: 'Airplane Policies',
      children: [
        _InfoItem(
          icon: Icons.smoking_rooms,
          title: 'No Smoking Policy',
          details: 'Smoking and vaping are strictly prohibited on all flights.',
        ),
        _InfoItem(
          icon: Icons.pets,
          title: 'Pet Policy',
          details:
              'Service animals welcome with documentation. Pets must be booked in advance.',
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Text(
            'Always check the latest Travel Advisories before your trip.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '© 2025 CEB Travel Solutions. All rights reserved.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// --- Custom Widgets ---
class _CustomExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> children;

  const _CustomExpansionTile({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Icon(icon, color: Colors.amberAccent, size: 30),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          collapsedIconColor: Colors.white70,
          iconColor: Colors.amberAccent,
          children: children,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String details;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.details,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 26.0, top: 4),
            child: Text(
              details,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
