import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

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
        child: Admin(userDetail: userDetail!),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

}