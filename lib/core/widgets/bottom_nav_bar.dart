import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:echoread/l10n/app_localizations.dart';

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

    final isAdmin = userRole == 'admin';

    switch (index) {
      case 0:
        targetRoute = '/home';
        break;
      case 1:
        targetRoute = isAdmin ? '/author-manage' : '/explore';
        break;
      case 2:
        targetRoute = isAdmin ? '/book-manage' : '/library';
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

  List<BottomNavigationBarItem> _navBarItems(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isAdmin = userRole == 'admin';

    return [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_sharp),
        label: localizations.home,
      ),
      BottomNavigationBarItem(
        icon: Icon(isAdmin ? Icons.person : Icons.explore),
        label: isAdmin ? localizations.author : localizations.explore,
      ),
      BottomNavigationBarItem(
        icon: Icon(isAdmin ? Icons.menu_book : Icons.library_books),
        label: isAdmin ? localizations.book : localizations.my_library,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.settings),
        label: localizations.settings_screen,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: widget.currentIndex,
      selectedItemColor: const Color(0xFFF56B00),
      unselectedItemColor: Colors.grey[600],
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
      onTap: (index) => _onItemTapped(context, index),
      items: _navBarItems(context),
    );
  }
}
