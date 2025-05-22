import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/bottom_nav_bar.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';

import 'package:echoread/features/user/presentation/widgets/setting_page.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  static const String routeName = '/setting';

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  Map<String, dynamic>? userDetail;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SettingsScreen(userDetail: userDetail!),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }
}