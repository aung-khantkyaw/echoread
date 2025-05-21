import 'package:flutter/material.dart';

import 'package:echoread/features/auth/services/auth_service.dart';

import 'package:echoread/core/widgets/profile_card.dart';

class Profile extends StatelessWidget {
  final Map<String, dynamic> userDetail;

  const Profile({super.key, required this.userDetail});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final profileImage = userDetail['profile_img']?.toString().isNotEmpty == true
        ? userDetail['profile_img']
        : 'assets/icon/app_icon.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileCard(
          name: userDetail['name'],
          email: userDetail['email'],
          profileImg: profileImage,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
          onPressed: () => authService.logout(context),
        ),
      ],
    );
  }
}