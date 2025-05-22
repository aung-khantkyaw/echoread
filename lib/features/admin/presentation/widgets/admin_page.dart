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
        : 'profile/pggchhf3zntmicvhbxns';

    return  Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileCard(
          name: userDetail['name'],
          email: userDetail['email'],
          profileImg: profileImage,
        ),
        const SizedBox(height: 10),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: GridView.count(
            physics: const NeverScrollableScrollPhysics(), // Prevent nested scrolling
            shrinkWrap: true, // Allows GridView inside SingleChildScrollView
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              IconCard(
                title: 'Author Mange',
                icon: Icons.person_rounded,
                onTap: () => Navigator.pushNamed(context, '/author-manage'),
              ),
              IconCard(
                title: 'Book Mange',
                icon: Icons.collections_bookmark_rounded,
                onTap: () => Navigator.pushNamed(context, '/book-manage'),
              ),
              IconCard(
                title: 'Downloaded',
                icon: Icons.download_sharp,
                onTap: () => Navigator.pushNamed(context, '/download-history'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
