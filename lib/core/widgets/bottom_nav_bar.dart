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
    String? currentRoute = ModalRoute.of(context)?.settings.name;
    String targetRoute = '';

    switch (index) {
      case 0:
        targetRoute = '/home';
        break;
      case 1:
        targetRoute = '/explore';
        break;
      case 2:
        targetRoute = '/library';
        break;
      case 3:
        targetRoute = '/setting';
        break;
      default:
        return;
    }

    if (currentRoute != targetRoute && targetRoute.isNotEmpty) {
      Navigator.pushReplacementNamed(context, targetRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      selectedItemColor: const Color(0xFFF56B00),
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