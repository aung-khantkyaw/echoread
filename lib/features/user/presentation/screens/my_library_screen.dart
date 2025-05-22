import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import '../../services/book_service.dart';
import '../widgets/my_library_page.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});
  static const String routeName = '/library';

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  final BookService _bookService = BookService();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _allBooks;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
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
        : 'profile/pggchhf3zntmicvhbxns';

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: commonAppBar(
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: MyLibraryScreen(allBooks: _allBooks ?? []),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), 
    );
  }

}