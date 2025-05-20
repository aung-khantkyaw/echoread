import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/features/user/services/book_service.dart'; // Import BookService

import '../widgets/home_page.dart';

class HomePage extends StatefulWidget { // Change to StatefulWidget
  const HomePage({super.key});
  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookService _bookService = BookService(); // Instantiate BookService

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _allBooks; // List to hold all books

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData(); // Load user detail and all books
  }

  Future<void> loadAllData() async {
    final detail = await getUserDetail();
    final books = await _bookService.getBooks(); // Fetch all books using BookService

    setState(() {
      userDetail = detail;
      _allBooks = books;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while data is loading
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Determine profile route and image for the AppBar
    final profileRoute = userDetail?['role']?.toString().isNotEmpty == true
        ? userDetail!['role'] == 'user' ? '/profile' : '/admin'
        : '/unauthorized';
    final profileImage = userDetail?['profile_img']?.toString().isNotEmpty == true
        ? userDetail!['profile_img']
        : 'assets/icon/app_icon.png'; // Default image

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Consistent background color
      appBar: commonAppBar( // Use the common AppBar
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Pass the fetched books list to the HomePage widget (now a content widget)
        child: HomeContentPage(allBooks: _allBooks ?? []), // Renamed to HomeContentPage to avoid conflict
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Highlight Home tab (index 0)
    );
  }
}