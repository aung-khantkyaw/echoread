import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/common_app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import '../widgets/profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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
        child: Profile(userDetail: userDetail!),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

}