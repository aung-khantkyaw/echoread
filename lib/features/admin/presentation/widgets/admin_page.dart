import 'package:flutter/material.dart';

import 'package:echoread/features/auth/services/auth_service.dart';

class Admin extends StatelessWidget {
  final Map<String, dynamic> userDetail;

  const Admin({super.key, required this.userDetail});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final profileImage = userDetail['profile_img']?.toString().isNotEmpty == true
        ? userDetail['profile_img']
        : 'assets/icon/app_icon.png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${userDetail['name']}!',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        CircleAvatar(
          radius: 40,
          backgroundImage: AssetImage(profileImage),
        ),
        const SizedBox(height: 16),
        Text(
          'Email: ${userDetail['email']}',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'Role: ${userDetail['role']}',
          style: const TextStyle(fontSize: 16),
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
