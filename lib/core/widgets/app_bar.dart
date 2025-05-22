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
        fontWeight: FontWeight.w900,
        fontFamily: 'Cinzel'
      ),
    ),
    centerTitle: false,
    actions: [
      GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, '/admin');
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2, // border width
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                CloudinaryConfig.baseUrl(profileImagePath, MediaType.image),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
