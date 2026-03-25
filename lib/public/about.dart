import 'package:flutter/material.dart';
import 'package:ticketing_flutter/public/bookpage.dart';
import 'package:ticketing_flutter/public/book.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _About();
}

class _About extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF000000), Color(0xFF111827), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 🖼️ Hero Section (keeps same gradient)
              Stack(
                children: [
                  // Background image with slight transparency
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/airplane_banner.jpg'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                    foregroundDecoration: BoxDecoration(
                      color: Colors.black.withOpacity(
                        0.25,
                      ), // soft overlay only
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(60),
                        bottomRight: Radius.circular(60),
                      ),
                    ),
                  ),

                  // Title and Button
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.flight_takeoff,
                          color: Colors.white,
                          size: 100,
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          "Airlines Ticketing",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.blueAccent,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Your Journey Begins Here",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 35,
                              vertical: 15,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 6,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Book(),
                              ),
                            );
                          },

                          child: const Text(
                            "Book Now",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // ✨ Body Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildCardSection(
                      "Who We Are",
                      "Airlines Ticketing is a modern flight ticketing platform dedicated to making air travel more accessible, affordable, and stress-free. Whether you're booking a business trip, family vacation, or spontaneous getaway, our goal is to make your journey smooth from takeoff to landing.",
                    ),
                    _buildCardSection(
                      "Our Mission",
                      "We aim to connect people across destinations by offering reliable booking services, transparent pricing, and exceptional customer support — all in one easy-to-use app.",
                    ),
                    const SizedBox(height: 10),
                    _buildSectionTitle("What We Offer"),
                    const SizedBox(height: 10),
                    _buildFeatureCard(
                      Icons.airplane_ticket,
                      "Easy & Secure Flight Booking",
                      "Book one-way, round-trip, or multi-city flights in just a few taps.",
                    ),
                    _buildFeatureCard(
                      Icons.attach_money,
                      "Transparent Pricing",
                      "No hidden fees — what you see is what you pay.",
                    ),
                    _buildFeatureCard(
                      Icons.support_agent,
                      "24/7 Customer Support",
                      "We’re always here to assist you before, during, and after your flight.",
                    ),
                    _buildFeatureCard(
                      Icons.event_available,
                      "Flexible Travel Options",
                      "Easily modify or cancel bookings when plans change.",
                    ),
                    const SizedBox(height: 20),
                    _buildCardSection(
                      "Our Vision",
                      "To become the most trusted digital airline ticketing service — bridging distances, one flight at a time.",
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle("Contact Us"),
                    const SizedBox(height: 10),
                    _buildContactRow(
                      Icons.email_outlined,
                      "airlinesticketing@gmail.com",
                    ),
                    _buildContactRow(Icons.phone_outlined, "+63 912 345 6789"),
                    _buildContactRow(
                      Icons.location_on_outlined,
                      "ACLC College of Mandaue",
                    ),
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 40),
                      child: const Text(
                        "© 2025 Airlines Ticketing. All rights reserved.",
                        style: TextStyle(color: Colors.white60, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Reusable Components
  static Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  static Widget _buildCardSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.white70,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  static Widget _buildFeatureCard(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[200], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.blue[200]),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(fontSize: 15, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
