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
      case 1: // Author List (New)
        targetRoute = '/author-list'; // New route name
        break;
      case 2: // Profile (Index shifted)
        if (userRole == 'admin') {
          targetRoute = '/admin';
        } else if (userRole == 'user') {
          targetRoute = '/profile';
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Access denied: Unknown role')),
          );
          return; // Stop navigation if role is unknown
        }
        break;
    // If more items are added, add cases here
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
      currentIndex: widget.currentIndex,
      selectedItemColor: Colors.blueAccent,
      unselectedItemColor: Colors.grey[600], // Add unselected color for better visibility
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
      onTap: (index) => _onItemTapped(context, index),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_sharp),
          label: 'Home',
        ),
        BottomNavigationBarItem( // New Author Item
          icon: Icon(Icons.people), // Or a suitable icon like Icons.book_rounded
          label: 'Authors',
        ),
        BottomNavigationBarItem( // Profile Item (Index Shifted)
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
        // If more items are added, add them here
      ],
      // type: BottomNavigationBarType.fixed, // Optional: Use if you have more than 3 items
    );
  }
}