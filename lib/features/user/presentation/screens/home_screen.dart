import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';

import 'package:echoread/features/user/services/book_service.dart';
import 'package:echoread/features/user/presentation/widgets/home_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    final books = await _bookService.getBooks();

    setState(() {
      userDetail = detail;
      _allBooks = books;
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
        padding: const EdgeInsets.all(10.0),
        child: HomeContentPage(allBooks: _allBooks ?? []),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}