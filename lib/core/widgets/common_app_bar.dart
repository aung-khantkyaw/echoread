import 'package:flutter/material.dart';

import '../config/cloudinary_config.dart';

PreferredSizeWidget commonAppBar({
  required BuildContext context,
  required String profileRoute,
  required String profileImagePath,
  String? title = 'EchoRead',
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    title: Text(
      title!,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: false,
    actions: [
      GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, profileRoute);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(
              CloudinaryConfig.baseUrl(profileImagePath),
            ),
            // no onBackgroundImageError here
          ),
        ),
      ),
    ],
  );
}
