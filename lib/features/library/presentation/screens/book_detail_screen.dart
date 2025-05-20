import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart'; // Assuming getUserDetail is defined here
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import '../../services/book_service.dart'; // Assuming BookService is here
import '../../services/author_service.dart';
import '../widgets/book_detail_page.dart'; // Ensure this path is correct for your BookDetailPage widget

class BookDetailScreen extends StatefulWidget {
  const BookDetailScreen({super.key});
  static const String routeName = '/book-detail'; // Define the route name

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final BookService _bookService = BookService();
  final AuthorService _authorService = AuthorService();

  Map<String, dynamic>? userDetail;
  Map<String, dynamic>? _bookDetail; // To hold fetched book details
  Map<String, dynamic>? _authorDetail; // To hold fetched author details (will contain 'name' key)

  String? _bookId; // Book ID passed as argument

  bool isLoading = true;
  bool bookNotFound = false; // Flag for when book is not found

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load if _bookId hasn't been set yet (to prevent multiple loads)
    if (_bookId == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) { // Expecting bookId as a String argument
        _bookId = args;
        loadData(); // Trigger data loading
      } else {
        // Handle case where bookId is not provided or invalid
        setState(() {
          isLoading = false;
          bookNotFound = true;
        });
      }
    }
  }

  Future<void> loadData() async {
    // If bookId is still null, set loading to false and mark as not found
    if (_bookId == null) {
      setState(() {
        isLoading = false;
        bookNotFound = true;
      });
      return;
    }

    // Fetch user details and book details concurrently
    final detail = await getUserDetail(); //
    final book = await _bookService.getBookDetail(_bookId!); //

    if (book != null) {
      final String? authorId = book['author_id']; // This field name should match your book collection in Firestore
      if (authorId != null) {
        // _authorService.getAuthorDetail correctly handles nullable String
        // And its implementation in AuthorService will return map with 'name' key
        _authorDetail = await _authorService.getAuthorDetail(authorId);
      }
    }

    setState(() {
      userDetail = detail; // Update user details state
      _bookDetail = book; // Update book details state
      isLoading = false; // Set loading to false once data is fetched
      bookNotFound = book == null; // Update bookNotFound flag
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator while data is being fetched
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Show "Book Not Found" message if book is null or not found
    if (bookNotFound || _bookDetail == null) {
      return Scaffold(
        appBar: commonAppBar(
          context: context,
          profileRoute: '/home', // Or a more appropriate fallback route
          profileImagePath: 'assets/icon/app_icon.png', // Default image
          title: 'Book Not Found',
        ),
        body: const Center(
          child: Text('Book not found or an error occurred.'),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Default to Home tab
      );
    }

    // Determine profile route based on user role, providing fallbacks
    final profileRoute = userDetail?['role']?.toString().isNotEmpty == true
        ? userDetail!['role'] == 'user' ? '/profile' : '/admin' // Assuming '/admin' for admin role
        : '/unauthorized'; // Default route if user role is not determined

    // Determine profile image path, providing a default fallback
    final profileImage = userDetail?['profile_img']?.toString().isNotEmpty == true
        ? userDetail!['profile_img']
        : 'assets/icon/app_icon.png'; // Default image if profile_img is null or empty

    return Scaffold(
      backgroundColor: Colors.lightBlue[50], // Consistent background color
      appBar: commonAppBar(
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,
        title: _bookDetail!['book_name'] ?? 'Book Detail', // Set AppBar title to book name
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Pass the fetched book and author details to the BookDetailPage widget
        child: BookDetailPage(
          bookDetail: _bookDetail!, // Non-null book details
          authorDetail: _authorDetail, // Nullable author details
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0), // Default to Home tab
    );
  }
}
