import 'package:flutter/material.dart';

class UserAddOnsPage extends StatelessWidget {
  const UserAddOnsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        title: const Text('Add-ons'),
        backgroundColor: Colors.orangeAccent,
        foregroundColor: Colors.black,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add Seats, Meals & Baggage',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildAddOnCard(
                icon: Icons.chair,
                title: 'Seat Selection',
                description: 'Choose your preferred seat',
              ),
              const SizedBox(height: 16),
              _buildAddOnCard(
                icon: Icons.restaurant,
                title: 'Meals',
                description: 'Pre-order your meals',
              ),
              const SizedBox(height: 16),
              _buildAddOnCard(
                icon: Icons.luggage,
                title: 'Baggage',
                description: 'Add extra baggage allowance',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddOnCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.1),
      child: ListTile(
        leading: Icon(icon, color: Colors.orangeAccent, size: 32),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          description,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white54,
          size: 16,
        ),
        onTap: () {
          // Handle add-on selection
        },
      ),
    );
  }
}
