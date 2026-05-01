import 'package:flutter/material.dart';
import 'package:ticketing_flutter/widgets/disable_route_pop.dart';

class UserSpecialAssistancePage extends StatelessWidget {
  const UserSpecialAssistancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DisableRoutePop(child: Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      appBar: AppBar(
        title: const Text('Special Assistance'),
        backgroundColor: Colors.purpleAccent,
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
                'Request Travel Support',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'We\'re here to help',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildAssistanceOption('Wheelchair Assistance'),
                      _buildAssistanceOption('Medical Equipment'),
                      _buildAssistanceOption('Special Meals'),
                      _buildAssistanceOption('Travel with Children'),
                      _buildAssistanceOption('Pet Travel'),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle assistance request
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Submit Request'),
                        ),
                      ),
                    ],
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

  Widget _buildAssistanceOption(String option) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: false,
            onChanged: (value) {},
            checkColor: Colors.black,
            fillColor: MaterialStateProperty.all(Colors.purpleAccent),
          ),
          Text(option, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
