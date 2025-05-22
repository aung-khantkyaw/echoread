import 'package:flutter/material.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';

import 'package:echoread/core/widgets/profile_card.dart';
import '../../../auth/services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> userDetail;

  const SettingsScreen({super.key, required this.userDetail});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 30, left: 16, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );

  Widget settingsItem(String label, {String? value, VoidCallback? onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: value != null
          ? Text(
        value,
        style: const TextStyle(fontSize: 16),
      )
          : const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap ?? () => showSnackBar(context, '$label tapped'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userDetail = widget.userDetail; // ✅ Correct usage
    final AuthService authService = AuthService();

    final profileImage = userDetail['profile_img']?.toString().isNotEmpty == true
        ? userDetail['profile_img']
        : 'profile/pggchhf3zntmicvhbxns';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileCard(
            name: userDetail['name'],
            email: userDetail['email'],
            profileImg: profileImage,
          ),
          sectionTitle('Account'),
          settingsItem('Update Email'),
          // sectionTitle('Manage subscription'),
          // settingsItem('Membership', value: 'Basic'),
          // sectionTitle('Content'),
          // settingsItem('Language', value: 'English'),
          // sectionTitle('Notifications'),
          // settingsItem('Push Notifications'),
          sectionTitle('About'),
          settingsItem('Privacy Policy'),
          settingsItem('Terms of Service'),
          settingsItem('Help Center'),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                authService.logout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Log out', style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Confirm Deletion"),
                    content: const Text("Are you sure you want to delete your account?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          authService.deleteAccount(context); // Call delete function
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text('Delete Account', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
