import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Text(
        title,
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
        title: const Text('Help Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to the Help Center! If you have questions or need assistance, you're in the right place.",
              style: TextStyle(fontSize: 16),
            ),

            _buildSectionTitle("Save Books or Audio"),
            _buildBulletPoint("Tap on any book/audio to open the detail page."),
            _buildBulletPoint("Press save to device."),
            _buildBulletPoint("The book/audio files will be saved in your device."),

            _buildSectionTitle("Search and Filter"),
            _buildBulletPoint("Use the search bar to find books, audios by title or author names."),

            _buildSectionTitle("Read Ebooks"),
            _buildBulletPoint("Tap on any book you prefer and it will open the PDF file reader area."),

            _buildSectionTitle("Listen to Audio"),
            _buildBulletPoint("Tap on audio file and can play all the audios available."),

            _buildSectionTitle("Account Help"),
            _buildBulletPoint("If you signed in with an account, your recent viewed PDFs and audios are saved to your profile."),
            _buildBulletPoint("To logout, go to Profile > Log Out."),

            _buildSectionTitle("Contact Us"),
            const Text(
              "Still need help? Reach out anytime at:",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const SelectableText(
              "echoReadAdmin@gmail.com",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
