import 'package:flutter/material.dart';

import 'package:echoread/core/utils/func.dart';
import 'package:echoread/features/auth/services/auth_service.dart';

class Admin extends StatefulWidget {
  const Admin({Key? key}) : super(key: key);

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  Map<String, dynamic>? userDetail;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

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
              Text('Welcome Admin, ${user['name']}', style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => Navigator.pushNamed(context, '/profile'),
                child: const Text(
                  'Go to Profile',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                onPressed: () => _authService.logout(context),
              ),
            ],
          ),
        );
      },
    );
  }
}
