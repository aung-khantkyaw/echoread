import 'package:echoread/features/user/presentation/widgets/about_us_page.dart';
import 'package:echoread/features/user/presentation/widgets/privacy_policy_page.dart';
import 'package:echoread/features/user/presentation/widgets/teams_of_service.dart';
import 'package:echoread/features/user/presentation/widgets/update_account_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/l10n/app_localizations.dart';

import 'package:echoread/core/widgets/system_widget.dart';
import 'package:echoread/core/widgets/profile_card.dart';

import 'package:echoread/features/auth/services/auth_service.dart';

import 'package:echoread/main.dart';

import 'help_center_page.dart';

class SettingsScreen extends StatefulWidget {
  final Map<String, dynamic> userDetail;

  const SettingsScreen({super.key, required this.userDetail});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
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
              print('Navigating with userId: ${FirebaseAuth.instance.currentUser!.uid} and username: ${userDetail['name']}');

              Navigator.pushNamed(
                context,
                AccountUpdatePage.routeName,
                arguments: {
                  'accountId': FirebaseAuth.instance.currentUser!.uid,
                  'username': userDetail['name'],
                  'profileImg': profileImage,
                },

              );

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
            AppLocalizations.of(context)!.about_us,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutUsPage()),
              );
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.privacy_policy,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
              );

            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.terms_of_service,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
              );
            },
          ),
          SystemWidgets.sectionItem(
            context,
            AppLocalizations.of(context)!.help_center,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpCenterPage()),
              );
            },
          ),

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
