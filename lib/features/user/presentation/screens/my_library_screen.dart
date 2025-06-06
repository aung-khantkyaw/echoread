import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import 'package:echoread/core/widgets/custom_gif_loading.dart';
import 'package:echoread/features/user/services/book_service.dart';
import 'package:echoread/features/user/presentation/widgets/my_library_page.dart';

class MyLibraryPage extends StatefulWidget {
  const MyLibraryPage({super.key});
  static const String routeName = '/library';

  @override
  State<MyLibraryPage> createState() => _MyLibraryPageState();
}

class _MyLibraryPageState extends State<MyLibraryPage> {
  final BookService _bookService = BookService();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _currentReadingBooks;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    final detail = await getUserDetail();
    final currentReadingBooks = await _bookService.getCurrentlyReadingBookByUserId(FirebaseAuth.instance.currentUser!.uid);

    setState(() {
      userDetail = detail;
      _currentReadingBooks = currentReadingBooks;
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
        child: MyLibraryScreen(currentReadingBooks: _currentReadingBooks ?? []),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2), 
    );
  }

}