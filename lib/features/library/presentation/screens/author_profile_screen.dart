import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';

import '../widgets/author_profile_page.dart';

class AuthorProfilePage extends StatefulWidget {
  final String authorId;

  const AuthorProfilePage({super.key, required this.authorId});
  static const String routeName = '/author-profile';

  @override
  State<AuthorProfilePage> createState() => _AuthorProfilePageState();
}


class _AuthorProfilePageState extends State<AuthorProfilePage> {
  
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
        //title: 'Authors', // Set title for Authors screens
      ),
      body: AuthorProfileScreen(authorId: widget.authorId),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }
}