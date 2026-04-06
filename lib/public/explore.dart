import 'package:flutter/material.dart';
import 'package:ticketing_flutter/public/bookpage.dart';
import 'package:ticketing_flutter/public/about.dart';
import 'package:ticketing_flutter/public/travel_info.dart';
import 'package:ticketing_flutter/public/manage/manage.dart';
import 'package:ticketing_flutter/auth/login.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePage();
}

class _ExplorePage extends State<ExplorePage> {
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
                onTap: () => _nav(const TravelInfoPage()),
              ),
              _drawerItem(
                icon: Icons.explore,
                label: 'Explore',
                onTap: () => _navReplace(const ExplorePage()),
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
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header banner
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    image: const DecorationImage(
                      image: AssetImage('assets/singapore.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                        ],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: const Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Explore Beautiful Places',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Philippine Destinations
                const Text(
                  'Philippines Destinations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: const [
                    DestinationCard(
                      imagePath: 'assets/boracay.webp',
                      title: 'Boracay',
                      subtitle: 'White Beach Paradise',
                    ),
                    DestinationCard(
                      imagePath: 'assets/palawan.webp',
                      title: 'Palawan',
                      subtitle: 'The Last Frontier',
                    ),
                    DestinationCard(
                      imagePath: 'assets/singapore.webp',
                      title: 'Siargao',
                      subtitle: 'Surfing Capital',
                    ),
                    DestinationCard(
                      imagePath: 'assets/bohol.webp',
                      title: 'Bohol',
                      subtitle: 'Chocolate Hills',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // International Destinations
                const Text(
                  'International Destinations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),

                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: const [
                    DestinationCard(
                      imagePath: 'assets/singapore.webp',
                      title: 'Tokyo',
                      subtitle: 'City of the Rising Sun',
                    ),
                    DestinationCard(
                      imagePath: 'assets/singapore.webp',
                      title: 'Seoul',
                      subtitle: 'K-Culture Capital',
                    ),
                    DestinationCard(
                      imagePath: 'assets/singapore.webp',
                      title: 'Singapore',
                      subtitle: 'Garden City',
                    ),
                    DestinationCard(
                      imagePath: 'assets/singapore.webp',
                      title: 'Dubai',
                      subtitle: 'Luxury in the Desert',
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // Footer
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      "© 2025 Airlines Ticketing. All Rights Reserved.",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 13,
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
}

// --- DestinationCard Widget ---
class DestinationCard extends StatefulWidget {
  final String imagePath;
  final String title;
  final String subtitle;

  const DestinationCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subtitle,
  });

  @override
  State<DestinationCard> createState() => _DestinationCardState();
}

class _DestinationCardState extends State<DestinationCard> {
  double _scale = 1.0;
  String get _heroTag => '${widget.imagePath}_${widget.title}';

  void _onTapDown(TapDownDetails details) {
    setState(() => _scale = 1.05);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _scale = 1.0);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ImageViewer(imagePath: widget.imagePath, heroTag: _heroTag),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: Hero(
          tag: _heroTag,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(widget.imagePath),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              offset: Offset(1, 1),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- ImageViewer Widget ---
class ImageViewer extends StatelessWidget {
  final String imagePath;
  final String heroTag;

  const ImageViewer({
    super.key,
    required this.imagePath,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
