import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import '../widgets/profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Profile(),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
