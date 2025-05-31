import 'package:flutter/material.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({Key? key}) : super(key: key);

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
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Please read these Terms of Service carefully before using our app. By accessing or using our app you agree to be bound by these terms.",
              style: TextStyle(fontSize: 16),
            ),

            _buildSectionTitle("Use of the App"),
            _buildBulletPoint("Use the app only for personal, non-commercial purposes."),
            _buildBulletPoint("Provide accurate information during registration."),

            _buildSectionTitle("You MUST NOT:"),
            _buildBulletPoint("Distribute, copy or resell any content from the app."),
            _buildBulletPoint("Use the app to spread harmful, abusive or illegal content."),
            _buildBulletPoint("Attempt to hack, exploit or disrupt the app or its users."),

            _buildSectionTitle("Content Ownership"),
            const Text(
              "All books, audio files and app content are owned by us or our content providers. You may not reproduce or distribute any content without permission.",
              style: TextStyle(fontSize: 16),
            ),

            _buildSectionTitle("Termination"),
            const Text(
              "We may suspend or terminate your access to the app if:",
              style: TextStyle(fontSize: 16),
            ),
            _buildBulletPoint("You violate these Terms."),
            _buildBulletPoint("You misuse the app or its services."),

            _buildSectionTitle("Disclaimer"),
            _buildBulletPoint("We do our best to keep the app running smoothly, but we don't guarantee:"),
            _buildBulletPoint("The app will always be available or error-free."),
            _buildBulletPoint("That all content is accurate or up-to-date."),

            _buildSectionTitle("Contact Us"),
            const Text(
              "If you have any questions about these Terms, contact us at:",
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
