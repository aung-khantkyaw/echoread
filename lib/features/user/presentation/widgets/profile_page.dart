import 'package:flutter/material.dart';
import 'package:echoread/core/utils/func.dart';

import 'package:echoread/features/auth/services/auth_service.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  Map<String, dynamic>? userDetail;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return FutureBuilder<Map<String, dynamic>?>(
      future: getUserDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = snapshot.data!;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Welcome User, ${user['name']}. This is your Profile', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),

              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () => authService.logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
