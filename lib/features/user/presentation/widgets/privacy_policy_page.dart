import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("•  ", style: TextStyle(fontSize: 18)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "EchoRead is committed to protecting your privacy. This Privacy Policy explains how we collect, use and protect your information when you use our app.",
              style: TextStyle(fontSize: 16),
            ),

            _buildSectionTitle("Information We Collect"),
            _buildBulletPoint("Personal Info: Name and email"),
            _buildBulletPoint("Usage Data: Books/audio downloaded, search history and activity logs"),
            _buildBulletPoint("Device info: Device model"),
            _buildBulletPoint("Storage data: Downloaded books/audio"),

            _buildSectionTitle("How We Use Your Data"),
            _buildBulletPoint("Display your download history"),
            _buildBulletPoint("Enable personalized features (like recently read/listened books)"),

            _buildSectionTitle("What We Don't Do"),
            _buildBulletPoint("Sell or rent your personal data"),
            _buildBulletPoint("Access or store your passwords"),
            _buildBulletPoint("Track your location without permission"),

            _buildSectionTitle("Data Security"),
            const Text(
              "We use Firebase's secure cloud infrastructure and encryption to protect your data from unauthorized access.",
              style: TextStyle(fontSize: 16),
            ),

            _buildSectionTitle("Your Rights"),
            _buildBulletPoint("View or delete your account data"),
            _buildBulletPoint("Request removal of download history"),
            _buildBulletPoint("Revoke access anytime by logging out or uninstalling the app"),

            _buildSectionTitle("Contact Us"),
            const Text(
              "If you have questions or concerns about these policies, contact us at:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const SelectableText(
              "echoReadAdmin@gmail.com",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}
