import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/core/utils/func.dart';

import 'package:echoread/features/admin/services/author_manage_service.dart';

import '../widgets/author_manage_page.dart';

class AuthorManagePage extends StatefulWidget {
  const AuthorManagePage({super.key});
  static const String routeName = '/author-manage';

  @override
  State<AuthorManagePage> createState() => _AuthorManagePageState();
}

class _AuthorManagePageState extends State<AuthorManagePage> {
  final AuthorManageService _authorManageService = AuthorManageService();

  Map<String, dynamic>? userDetail;
  List<Map<String, dynamic>>? _authors;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final detail = await getUserDetail();
    final authors = await _authorManageService.getAuthors();

    setState(() {
      userDetail = detail;
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
        child: AuthorManage(authorsList: _authors ?? []),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}
