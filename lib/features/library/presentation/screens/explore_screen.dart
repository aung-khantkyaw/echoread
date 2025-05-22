import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import '../../services/author_service.dart';
import '../widgets/explore_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});
  static const String routeName = '/explore';

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final AuthorService _authorService = AuthorService();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _allAuthors;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    final detail = await getUserDetail();
    final authors = await _authorService.getAuthors();

    setState(() {
      userDetail = detail;
      _allAuthors = authors;
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
        : 'profile/pggchhf3zntmicvhbxns'; // Default image

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Consistent background color
      appBar: commonAppBar( // Use the common AppBar
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,

      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        // Pass the fetched books list to the ExplorePage widget (now a content widget)
        child: ExplorerScreen(authorsList: _allAuthors ?? []), // Renamed to HomeContentPage to avoid conflict
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1), // Highlight Home tab (index 0)
    );
  }
}