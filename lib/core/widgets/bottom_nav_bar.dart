import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBar extends StatefulWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  String userRole = '';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole') ?? '';
    });
  }

  void _onItemTapped(BuildContext context, int index) {
    // Check if the current route is already the target route to avoid unnecessary navigation
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    String targetRoute = '';

    switch (index) {
      case 0: // Home
        targetRoute = '/home';
        break;
      case 1:
        targetRoute = '/explore'; // New route name
        break;
      case 2: // Author List (New)
        targetRoute = '/library'; // New route name
        break;
      case 3:
        targetRoute = '/setting';
        break;
      default:
        return; // Do nothing for unknown indices
    }

    // Only navigate if the target route is different from the current route
    if (currentRoute != targetRoute && targetRoute.isNotEmpty) {
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_sharp), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.explore_sharp), label: 'Explore'),
        BottomNavigationBarItem(icon: Icon(Icons.local_library_sharp), label: 'My Library'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Setting'),
      ],
    );
  }
}