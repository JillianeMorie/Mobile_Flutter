import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';
import 'package:ticketing_flutter/user/userabout.dart';
import 'package:ticketing_flutter/user/user_explore.dart';
import 'package:ticketing_flutter/user/user_travel_info.dart';
import 'package:ticketing_flutter/user/user_manage/user_manage.dart';
import 'package:ticketing_flutter/user/account_details.dart';
import 'package:ticketing_flutter/user/user_book.dart';
import 'package:ticketing_flutter/user/user_logout.dart';

// --- CEBU PACIFIC INSPIRED COLOR PALETTE ---
const Color cebPrimaryBlue = Color(0xFF15A7E0);
const Color cebDarkBlue = Color(0xFF1875BA);
const Color cebTeal = Color(0xFF039482);
const Color cebOrange = Color(0xFFFF9900);
const Color cebBackground = Color(0xFFF0F4F8);

// --- NEW DARK GRADIENT COLORS ---
const Color gradDarkStart = Color(0xFF000000);
const Color gradDarkMid = Color(0xFF111827);
const Color gradDarkEnd = Color(0xFF1E3A8A);

class UserFlightBookingApp extends StatelessWidget {
  const UserFlightBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DisableRoutePop(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: cebDarkBlue,
          scaffoldBackgroundColor: gradDarkMid,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: cebDarkBlue,
            secondary: cebTeal,
          ),
          fontFamily: 'Inter',
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          useMaterial3: true,
        ),
        home: const UserBookPage(),
      ),
    );
  }
}

class UserBookPage extends StatefulWidget {
  const UserBookPage({super.key});

  @override
  State<UserBookPage> createState() => _UserBookPageState();
}

class _UserBookPageState extends State<UserBookPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [gradDarkStart, gradDarkMid, gradDarkEnd],
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
                    colors: [gradDarkStart, gradDarkMid, gradDarkEnd],
                  ),
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ),

              // Drawer Items
              _drawerItem(
                icon: Icons.flight,
                label: 'Book',
                onTap: () => _navReplace(const UserFlightBookingApp()),
              ),
              _drawerItem(
                icon: Icons.manage_accounts,
                label: 'Manage',
                onTap: () => _nav(const UserManagePage()),
              ),
              _drawerItem(
                icon: Icons.info,
                label: 'Travel Info',
                onTap: () => _nav(const UserTravelInfoPage()),
              ),
              _drawerItem(
                icon: Icons.explore,
                label: 'Explore',
                onTap: () => _nav(const UserExplore()),
              ),
              _drawerItem(
                icon: Icons.home,
                label: 'About',
                onTap: () => _nav(const Userabout()),
              ),

              _drawerItem(
                icon: Icons.account_circle,
                label: 'My Account',
                onTap: () => _nav(const UserAccountDetailsPage()),
              ),
              _drawerItem(
                icon: Icons.logout,
                label: 'Logout',
                onTap: () => logoutUserAndShowLogin(context),
              ),
            ],
          ),
        ),

        backgroundColor: Colors.transparent,
        appBar: AppBar(
          // Root MaterialApp uses default light M3 theme; without these, the
          // bar uses ColorScheme.surface (white) when this page is pushed
          // directly (e.g. from UserBook after login), not via UserFlightBookingApp.
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          foregroundColor: Colors.white,
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 28),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          title: const Text("Book Your Flight"),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: cebPrimaryBlue,
            labelColor: cebOrange,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: "Seat Sale"),
              Tab(text: "Super Pass"),
            ],
          ),
        ),

        body: TabBarView(
          controller: _tabController,
          children: const [UserSeatSaleTab(), UserSuperPassTab()],
        ),
      ),
    );
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
}

// --- TAB 1 (Seat Sale) ---
class UserSeatSaleTab extends StatelessWidget {
  const UserSeatSaleTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          "Latest Seat Sales & Promos",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),

        _promoCard(
          context,
          title: "PISO FARE is BACK!",
          destination: "Domestic Destinations",
          price: "Starting at ₱1.00",
          endDate: "Sale ends in 2 days",
          color: cebOrange,
        ),

        _promoCard(
          context,
          title: "International Travel Deals",
          destination: "Tokyo, Singapore, Seoul",
          price: "Up to 50% OFF",
          endDate: "Sale ends in 5 days",
          color: cebTeal,
        ),

        _promoCard(
          context,
          title: "CEB Flexi Promo",
          destination: "Change your flight for FREE!",
          price: "Book flight now!",
          endDate: "Limited-time offer",
          color: cebDarkBlue,
        ),
      ],
    );
  }

  Widget _promoCard(
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
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UserBook()),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.5), width: 2),
            color: Colors.white,
          ),
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
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 5),
              Text(destination, style: const TextStyle(fontSize: 14)),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- TAB 2 (Super Pass) ---
class UserSuperPassTab extends StatelessWidget {
  const UserSuperPassTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "The CEB Super Pass",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Buy now, fly later. Your ticket to flexible domestic travel.",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 20),

          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "What is the CEB Super Pass?",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Buy a flight pass now and redeem it for any domestic route later!",
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 10),
                  Text("• One-way flight pass"),
                  Text("• Redeem anytime during the validity period"),
                  Text("• Perfect for last-minute travel"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cebOrange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserBook()),
              );
            },
            child: const Center(
              child: Text(
                "Book flight now!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
