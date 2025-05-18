import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import '../widgets/home_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String routeName = '/home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Home(),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
