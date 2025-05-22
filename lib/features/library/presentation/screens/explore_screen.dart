import 'package:echoread/core/widgets/custom_gif_loading.dart';
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
    if (isLoading) {
      return const GifLoader();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
      ),
      body: Padding(
        padding: const EdgeInsets.all(2.0),
        child: ExplorerScreen(authorsList: _allAuthors ?? []),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}