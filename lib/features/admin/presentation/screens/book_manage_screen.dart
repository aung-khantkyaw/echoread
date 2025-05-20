import 'package:echoread/features/admin/services/author_manage_service.dart';
import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';

import '../widgets/book_manage_page.dart';

import 'package:echoread/features/admin/services/book_manage_service.dart';

class BookManagePage extends StatefulWidget {
  const BookManagePage({super.key});
  static const String routeName = '/book-manage';

  @override
  State<BookManagePage> createState() => _BookManagePageState();
}

class _BookManagePageState extends State<BookManagePage> {
  final BookManageService _bookManageService = BookManageService();
  final AuthorManageService _authorManageService = AuthorManageService();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _books;
  List<Map<String, dynamic>>? _authors;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final detail = await getUserDetail();
    final books = await _bookManageService.getBooks();
    final authors = await _authorManageService.getAuthors();

    setState(() {
      userDetail = detail;
      _books = books;
      _authors = authors;
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
        : 'assets/icon/app_icon.png';

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: commonAppBar(
        context: context,
        profileRoute: profileRoute,
        profileImagePath: profileImage,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BookManage(booksList: _books ?? [], authorsList: _authors ?? []),
        // child: BookForm(
        //     authorsList: _books ?? [],
        //     onSubmit: (bookData) {
        //     print("Book Submitted: $bookData");
        //     // Save to list or backend here
        //   },
        // ),
      ),
    );
  }
}
