import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/features/library/services/book_service.dart';
import 'package:echoread/features/library/presentation/screens/book_detail_screen.dart'; // Import the new screens

import '../widgets/author_book_page.dart';

class AuthorBookScreen extends StatefulWidget {
  const AuthorBookScreen({super.key});
  static const String routeName = '/author-books';

  @override
  State<AuthorBookScreen> createState() => _AuthorBookScreenState();
}

class _AuthorBookScreenState extends State<AuthorBookScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController = TextEditingController();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _allBooks;
  List<Map<String, dynamic>> _filteredBooks = [];

  String? _authorId;
  String _authorName = 'Author Books';

  bool isLoading = true;
  String _searchQuery = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_authorId == null) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _authorId = args['authorId'] as String?;
        _authorName = args['authorName'] as String? ?? 'Author Books';
        if (_authorId != null) {
          loadData();
          _searchController.addListener(_onSearchChanged);
        } else {
          setState(() {
            isLoading = false;
            _allBooks = [];
            _filteredBooks = [];
          });
        }
      } else {
        setState(() {
          isLoading = false;
          _allBooks = [];
          _filteredBooks = [];
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    if (_authorId == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final detail = await getUserDetail();
    final books = await _bookService.getBooksByAuthorId(_authorId!);

    setState(() {
      userDetail = detail;
      _allBooks = books;
      _filteredBooks = books;
      isLoading = false;
    });
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterBooks();
    });
  }

  void _filterBooks() {
    if (_searchQuery.isEmpty) {
      _filteredBooks = _allBooks ?? [];
    } else {
      _filteredBooks = (_allBooks ?? []).where((book) {
        final bookName = book['book_name']?.toString().toLowerCase() ?? '';
        return bookName.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  // Helper method for search result item tap (now navigates to BookDetailScreen)
  void _navigateToBookDetail(BuildContext context, String bookId, String bookName) {
    Navigator.pushNamed(
      context,
      BookDetailScreen.routeName, // Use the defined routeName
      arguments: bookId, // Pass only the bookId as a String argument
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
        title: _authorName,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search books by name...',
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
          Expanded(
            child: _searchQuery.isEmpty
                ? AuthorBookPage(booksList: _allBooks ?? [])
                : _filteredBooks.isEmpty
                ? const Center(child: Text('No matching books found.'))
                : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.7,
              ),
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                final bookId = book['id'] ?? '';
                final bookName = book['book_name'] ?? 'Unknown Book';
                final bookImg = book['book_img']?.toString().isNotEmpty == true
                    ? book['book_img']
                    : 'assets/icon/app_icon.png';

                return GestureDetector(
                  onTap: () => _navigateToBookDetail(context, bookId, bookName),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Image.network(
                            bookImg,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/icon/app_icon.png',
                                fit: BoxFit.contain,
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            bookName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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