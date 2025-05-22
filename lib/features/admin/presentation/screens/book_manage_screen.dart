import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';
import 'package:echoread/core/utils/func.dart';

import 'package:echoread/features/admin/services/author_manage_service.dart';
import 'package:echoread/features/admin/services/book_manage_service.dart';

import '../widgets/book_manage_page.dart';

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
      return const GifLoader();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BookManage(booksList: _books ?? [], authorsList: _authors ?? []),
      ),
    );
  }
}
