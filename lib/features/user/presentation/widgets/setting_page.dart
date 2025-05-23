import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:echoread/core/widgets/system_widget.dart';
import 'package:echoread/core/widgets/profile_card.dart';

import 'package:echoread/features/auth/services/auth_service.dart';

import 'package:echoread/main.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> userDetail;

  const SettingsScreen({super.key, required this.userDetail});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Widget sectionTitle(String title) => Padding(
  //   padding: const EdgeInsets.only(top: 30, left: 16, bottom: 8),
  //   child: Text(
  //     title,
  //     style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
  //   ),
  // );
  //
  // Widget settingsItem(String label, {String? value, VoidCallback? onTap}) {
  //   return ListTile(
  //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
  //     title: Text(
  //       label,
  //       style: const TextStyle(fontSize: 16),
  //     ),
  //     trailing: value != null
  //         ? Text(
  //       value,
  //       style: const TextStyle(fontSize: 16),
  //     )
  //         : const Icon(Icons.arrow_forward_ios, size: 18),
  //     // onTap: onTap ?? () => showSnackBar(context, '$label tapped'),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final userDetail = widget.userDetail;
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
          SystemWidgets.sectionTitle(AppLocalizations.of(context)!.settings),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.update_account,
            onTap: () {
              Navigator.pushNamed(context, '/update-account');
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.password_reset,
            onTap: () {
              Navigator.pushNamed(context, '/reset-password');
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.email_address_change,
            onTap: () {
              Navigator.pushNamed(context, '/change-email');
            },
          ),

          SystemWidgets.sectionTitle(AppLocalizations.of(context)!.language),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.language,
            onTap: () {
              EchoReadApp.toggleLocale(context);
            },
            value: Localizations.localeOf(context).languageCode == 'en'
                ? 'English'
                : 'မြန်မာ',
          ),

          SystemWidgets.sectionTitle(AppLocalizations.of(context)!.about),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.privacy_policy,
            onTap: () {
              Navigator.pushNamed(context, '/privacy-policy');
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.terms_of_service,
            onTap: () {
              Navigator.pushNamed(context, '/terms');
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.help_center,
            onTap: () {
              Navigator.pushNamed(context, '/help');
            },
          ),

          // SystemWidgets.sectionTitle('Manage Account'),
          // SystemWidgets.sectionItem(context, 'Account', onTap: () {
          //   Navigator.pushNamed(context, '/home');
          // }),
          // // sectionTitle('Manage subscription'),
          // // settingsItem('Membership', value: 'Basic'),
          // // sectionTitle('Content'),
          // // settingsItem('Language', value: 'English'),
          // // sectionTitle('Notifications'),
          // // settingsItem('Push Notifications'),
          // SystemWidgets.sectionTitle('About'),
          // SystemWidgets.sectionItem(context, 'Privacy Policy'),
          // SystemWidgets.sectionItem(context, 'Terms of Service'),
          // SystemWidgets.sectionItem(context, 'Help Center'),
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
              child: Text(
                AppLocalizations.of(context)!.logout,
                style: const TextStyle(fontSize: 16),
              ),
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
                    title: Text(AppLocalizations.of(context)!.confirm_deletion),
                    content: Text(AppLocalizations.of(context)!.delete_account_confirm),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(AppLocalizations.of(context)!.cancel),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context); // Close dialog
                          authService.deleteAccount(context); // Call delete function
                        },
                        child: Text(
                          AppLocalizations.of(context)!.delete,
                          style: const TextStyle(color: Colors.red),
                        ),
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
              child: Text(
                AppLocalizations.of(context)!.delete_account,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
