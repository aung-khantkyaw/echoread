import 'package:flutter/material.dart';

import '../config/cloudinary_config.dart';

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String profileImg;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    required this.profileImg,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.black,
                        width: 2.0,
                      ),
                      // image: DecorationImage(
                      //   image: AssetImage(profileImg),
                      //   fit: BoxFit.cover,
                      // ),
                      image: DecorationImage(
                        image: NetworkImage(
                          CloudinaryConfig.baseUrl(profileImg),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    name,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    email,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
