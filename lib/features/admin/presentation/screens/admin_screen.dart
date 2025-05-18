import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import '../widgets/admin_page.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});
  static const String routeName = '/admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Admin(),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
