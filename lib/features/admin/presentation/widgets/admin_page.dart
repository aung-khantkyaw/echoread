import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/icon_card.dart';
import 'package:echoread/core/widgets/profile_card.dart';

class Admin extends StatelessWidget {
  final Map<String, dynamic> userDetail;

  const Admin({super.key, required this.userDetail});

  @override
  Widget build(BuildContext context) {
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
        // ElevatedButton.icon(
        //   icon: const Icon(Icons.logout),
        //   label: const Text('Logout'),
        //   onPressed: () => authService.logout(context),
        // ),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            padding: const EdgeInsets.all(16),
            children: [
              IconCard(title: 'Author', icon: Icons.person_rounded, onTap: (){Navigator.pushNamed(context, '/author-manage');}),
              IconCard(title: 'Book', icon: Icons.collections_bookmark_rounded, onTap: (){Navigator.pushNamed(context, '/book-manage');}),
            ],
          )
        )
      ],
    );
  }
}
