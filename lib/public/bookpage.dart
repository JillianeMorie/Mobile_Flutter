import 'package:flutter/material.dart';
import 'package:ticketing_flutter/public/book.dart';
import 'package:ticketing_flutter/public/about.dart';
import 'package:ticketing_flutter/public/explore.dart';
import 'package:ticketing_flutter/public/travel_info.dart';
import 'package:ticketing_flutter/public/manage/manage.dart';
import 'package:ticketing_flutter/auth/login.dart';
import 'package:ticketing_flutter/public/my_account_details.dart';
import 'package:ticketing_flutter/services/user_service.dart';

// --- CEBU PACIFIC INSPIRED COLOR PALETTE ---
const Color cebPrimaryBlue = Color(0xFF15A7E0); // Bright Blue/Cyan
const Color cebDarkBlue = Color(0xFF1875BA); // Darker Header Blue
const Color cebTeal = Color(0xFF039482); // Accent Green/Teal
const Color cebOrange = Color(0xFFFF9900); // Used for 'Sale' or urgency
const Color cebBackground = Color(0xFFF0F4F8); // Light background

// --- NEW DARK GRADIENT COLORS (From Home Widget) ---
const Color gradDarkStart = Color(0xFF000000); // Black
const Color gradDarkMid = Color(0xFF111827); // Very Dark Blue/Gray
const Color gradDarkEnd = Color(0xFF1E3A8A); // Darker Navy Blue

class FlightBookingApp extends StatelessWidget {
  const FlightBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Note: The Scaffold background will be overridden by the body's gradient
        primaryColor: cebDarkBlue,
        scaffoldBackgroundColor: gradDarkMid,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: cebDarkBlue,
          secondary: cebTeal,
        ),
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          // Set default AppBar background to transparent for the gradient to show
          color: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
      home: const BookPage(),
    );
  }
}

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadLoginState();
  }

  Future<void> _loadLoginState() async {
    final logged = await UserService().isLoggedIn();
    if (!mounted) return;
    setState(() => _isLoggedIn = logged);
  }

  @override
  Widget build(BuildContext context) {
    // 1. Wrap the entire view in a Container with the gradient to cover the whole screen
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradDarkStart, gradDarkMid, gradDarkEnd],
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
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
                  title: const Text(
                    'Book',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
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
                  leading: const Icon(
                    Icons.manage_accounts,
                    color: Colors.white,
                  ),
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
                  title: const Text(
                    'About',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const About(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    _isLoggedIn ? Icons.person : Icons.login,
                    color: Colors.white,
                  ),
                  title: Text(
                    _isLoggedIn ? 'My Account Details' : 'Login',
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            _isLoggedIn
                            ? const MyAccountDetailsPage()
                            : const LoginPage(),
                        transitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 2. Set Scaffold background to transparent so the wrapping gradient shows
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // 3. AppBar background is transparent (from theme, but set explicitly here too)
            backgroundColor: Colors.transparent,
            elevation: 0, // 4. Remove shadow
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            title: const Text('Book Your Flight'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(kToolbarHeight),
              child: Container(
                color:
                    Colors.transparent, // 5. TabBar background is transparent
                child: TabBar(
                  indicatorColor: cebPrimaryBlue,
                  // 6. Update label colors for visibility on a dark background
                  labelColor: cebOrange, // Bright orange for selected tab
                  unselectedLabelColor:
                      Colors.white70, // Muted white for unselected
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    // --- TAB ORDER: Seat Sale, Super Pass, Flights ---
                    Tab(text: 'Seat Sale'),
                    Tab(text: 'Super Pass'),
                    Tab(text: 'Flights'),
                  ],
                ),
              ),
            ),
          ),
          // 7. Body now only holds the TabBarView, the gradient is behind it
          body: const TabBarView(
            children: [
              // --- TAB CONTENT ORDER (must match the tabs above) ---
              SeatSaleTab(),
              SuperPassTab(),
              FlightsTab(),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 3: FLIGHTS (Standard Booking) ---
class FlightsTab extends StatelessWidget {
  const FlightsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // SingleChildScrollView allows the content to scroll if needed
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Type Toggle (One-Way / Round-Trip)
          Row(
            children: [
              _buildTripTypeButton('One-Way', true),
              const SizedBox(width: 10),
              _buildTripTypeButton('Round-Trip', false),
            ],
          ),
          const SizedBox(height: 20),

          // Origin and Destination Input Cards
          _buildLocationCard(
            context,
            title: 'Flying From',
            subtitle: 'Manila (MNL)',
            icon: Icons.flight_takeoff,
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            context,
            title: 'Flying To',
            subtitle: 'Cebu (CEB)',
            icon: Icons.flight_land,
          ),
          const SizedBox(height: 20),

          // Date and Passenger Selection
          Row(
            children: [
              Expanded(
                child: _buildDetailsCard(
                  context,
                  title: 'Departure Date',
                  subtitle: '24 Nov 2025',
                  icon: Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDetailsCard(
                  context,
                  title: 'Passengers',
                  subtitle: '1 Adult',
                  icon: Icons.person_outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Add flight search logic here
                _showSnackbar(context, 'Searching for flights...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: cebPrimaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Search Flights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildQuickLink(
            context,
            text: 'Manage Booking or Check-in',
            icon: Icons.edit_calendar_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? cebPrimaryBlue : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cebPrimaryBlue, width: 1.5),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: cebPrimaryBlue.withOpacity(0.3),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : cebPrimaryBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showSnackbar(context, 'Tapped to change $title'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, color: cebPrimaryBlue, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cebDarkBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: cebDarkBlue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showSnackbar(context, 'Tapped to change $title'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: cebTeal, size: 24),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: cebDarkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context, {
    required String text,
    required IconData icon,
  }) {
    return TextButton.icon(
      onPressed: () => _showSnackbar(context, 'Tapped $text'),
      icon: Icon(
        icon,
        color: cebPrimaryBlue,
      ), // Changed to a slightly brighter color for visibility
      label: Text(
        text,
        style: TextStyle(
          color:
              cebPrimaryBlue, // Changed to a slightly brighter color for visibility
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

// --- TAB 1: SEAT SALE (Promotions) ---
class SeatSaleTab extends StatelessWidget {
  const SeatSaleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text(
          'Latest Seat Sales & Promos',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Changed to white for visibility
          ),
        ),
        const SizedBox(height: 15),
        _buildPromoCard(
          context,
          title: 'PISO FARE is BACK!',
          destination: 'Domestic Destinations',
          price: 'Starting at P1.00 Base Fare',
          endDate: 'Sale ends 2 days',
          color: cebOrange,
        ),
        _buildPromoCard(
          context,
          title: 'International Travel Deals',
          destination: 'Tokyo, Singapore, Seoul',
          price: 'Up to 50% OFF',
          endDate: 'Sale ends in 5 days',
          color: cebTeal,
        ),
        _buildPromoCard(
          context,
          title: 'CEB Flexi Promo',
          destination: 'Change your flight for FREE!',
          price: 'Add-on starts at P499',
          endDate: 'Limited-time offer',
          color: cebDarkBlue,
        ),
      ],
    );
  }

  Widget _buildPromoCard(
    BuildContext context, {
    required String title,
    required String destination,
    required String price,
    required String endDate,
    required Color color,
  }) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing "$title" details.'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white, // Card remains white for content
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  endDate.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                destination,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.redAccent,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 2: SUPER PASS (Voucher Product) ---
class SuperPassTab extends StatelessWidget {
  const SuperPassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'The CEB Super Pass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Changed to white for visibility
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Buy now, fly later. Your ticket to flexible domestic travel.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70, // Changed to white70 for visibility
            ),
          ),
          const SizedBox(height: 20),

          // Core Feature Card
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [cebPrimaryBlue, cebTeal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'P99 BASE FARE VOUCHER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Use for one-way domestic flights.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 15),
                  Row(
                    children: [
                      Icon(
                        Icons.airplane_ticket,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Book 30 to 7 days before flight',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.lock_clock, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Travel Period: Dec 2025 - Dec 2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Buy Super Pass',
                  icon: Icons.shopping_cart_outlined,
                  color: cebOrange,
                  onTap: () => _showSnackbar(
                    context,
                    'Redirecting to Super Pass Purchase...',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Redeem Vouchers',
                  icon: Icons.redeem,
                  color: cebTeal,
                  onTap: () => _showSnackbar(
                    context,
                    'Starting Super Pass Redemption...',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // How-to Guide
          const Text(
            'How it works:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white, // Changed to white for visibility
            ),
          ),
          const SizedBox(height: 10),
          _buildFeatureBullet(
            '1. Purchase',
            'Buy the Super Pass voucher during the sale period.',
          ),
          _buildFeatureBullet(
            '2. Plan',
            'Decide your destination and date later.',
          ),
          _buildFeatureBullet(
            '3. Redeem',
            'Use the voucher to book a flight between 30 and 7 days of departure.',
          ),
          _buildFeatureBullet(
            '4. Pay Fees',
            'Only pay for government taxes and fuel surcharges at redemption.',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 4,
      ),
    );
  }

  Widget _buildFeatureBullet(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cebPrimaryBlue,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              step.substring(0, 1),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ), // Changed to white
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.white70),
                ), // Changed to white70
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
