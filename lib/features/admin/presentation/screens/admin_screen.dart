import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';

import '../widgets/admin_page.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});
  static const String routeName = '/admin';

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  Map<String, dynamic>? userDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserDetail();
  }

  Future<void> loadUserDetail() async {
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Admin(userDetail: userDetail!),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

}