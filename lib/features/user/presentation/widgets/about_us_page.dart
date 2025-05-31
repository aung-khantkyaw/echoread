import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'EchoRead',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'EchoRead is a simple and user-friendly app designed to bring stories and knowledge right to your fingertips — through both eBooks and audio.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Whether you love reading or prefer listening, our goal is to make learning and entertainment accessible anytime, anywhere.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'EchoRead is proudly developed through a collaboration between Mobile Flutter Online Class by Techal Florance, '
                  'Polytechnic University (Maubin) Faculty of Computing, and University of Computer Studies (Taunggyi).',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 20),
            Text(
              'Our Mission',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'To help people discover and enjoy books and audio content in a way that fits their lifestyle — whether by reading or listening.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'What We Offer',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• A growing library of eBooks and audio\n'
                  '• Easily readable PDF and audio files\n'
                  '• Personal reading lists with tracking and completion features\n'
                  '• Quick search and well-organized categories',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Built With Care',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This app is built using Flutter and powered by Firebase, focusing on performance, simplicity, and user privacy.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            SizedBox(height: 8),
            SelectableText(
              'Have suggestions, bugs, or feedback?\nWe\'d love to hear from you!\nechoReadAdmin@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
