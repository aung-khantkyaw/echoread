import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/features/admin/services/author_manage_service.dart'; // Use the existing service
import 'package:echoread/features/library/presentation/screens/author_book_screen.dart'; // For search result navigation

import '../widgets/author_list_page.dart'; // Import the new page widget

class AuthorListScreen extends StatefulWidget {
  const AuthorListScreen({super.key});
  static const String routeName = '/author-list'; // Define the route name

  @override
  State<AuthorListScreen> createState() => _AuthorListScreenState();
}

class _AuthorListScreenState extends State<AuthorListScreen> {
  final AuthorManageService _authorManageService = AuthorManageService();
  final TextEditingController _searchController = TextEditingController(); // Search input controller

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _allAuthors; // Original full list of authors
  List<Map<String, dynamic>> _filteredAuthors = []; // Filtered list for search results

  bool isLoading = true;
  String _searchQuery = ''; // Current search query

  @override
  void initState() {
    super.initState();
    loadData();
    // Add listener to search input
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    final detail = await getUserDetail();
    final authors = await _authorManageService.getAuthors();

    setState(() {
      userDetail = detail;
      _allAuthors = authors;
      _filteredAuthors = authors; // Initially show all authors
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterAuthors(); // Filter whenever search text changes
    });
  }

  void _filterAuthors() {
    if (_searchQuery.isEmpty) {
      _filteredAuthors = _allAuthors ?? [];
    } else {
      _filteredAuthors = (_allAuthors ?? []).where((author) {
        final authorName = author['name']?.toString().toLowerCase() ?? '';
        return authorName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Helper method for search result item tap (same as in AuthorListPage)
  void _navigateToAuthorBooks(BuildContext context, String authorId, String authorName) {
    Navigator.pushNamed(
      context,
      AuthorBookScreen.routeName,
      arguments: {
        'authorId': authorId,
        'authorName': authorName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final profileRoute = userDetail?['role']?.toString().isNotEmpty == true
        ? userDetail!['role'] == 'user' ? '/profile' : '/admin'
        : '/unauthorized';
    final profileImage = userDetail?['profile_img']?.toString().isNotEmpty == true
        ? userDetail!['profile_img']
        : 'assets/icon/app_icon.png';

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: commonAppBar(
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,
        //title: 'Authors', // Set title for Authors screens
      ),
      body: Column( // Use Column to stack search bar and content
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search authors...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
          Expanded( // Use Expanded to make the list take remaining space
            child: _searchQuery.isEmpty
                ? AuthorListPage(authorsList: _allAuthors ?? []) // Show full list if no search query
                : _filteredAuthors.isEmpty
                ? const Center(child: Text('No matching authors found.'))
                : ListView.builder( // Show filtered results
              itemCount: _filteredAuthors.length,
              itemBuilder: (context, index) {
                final author = _filteredAuthors[index];
                final authorId = author['id'] ?? '';
                final authorName = author['name'] ?? 'Unknown Author';
                return GestureDetector(
                  onTap: () => _navigateToAuthorBooks(context, authorId, authorName),
                  child: Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey, width: 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Text(
                        authorName,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}