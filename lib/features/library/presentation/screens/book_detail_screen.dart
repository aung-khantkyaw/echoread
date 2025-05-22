import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';

import '../widgets/book_detail_page.dart';

class BookDetailPage extends StatefulWidget {
  final String bookId;

  const BookDetailPage({super.key, required this.bookId});
  static const String routeName = '/book-detail';

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {

  Map<String, dynamic>? userDetail;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> loadData() async {
    final detail = await getUserDetail();

    setState(() {
      userDetail = detail;
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
      body: BookDetailsScreen(bookId: widget.bookId),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}