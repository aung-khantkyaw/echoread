import 'package:flutter/material.dart';

// ignore: non_constant_identifier_names
PreferredSizeWidget commonAppBar({
  required BuildContext context,
  required String profileRoute,
  required String profileImagePath,
  String? title = 'EchoRead', // Set 'EchoRead' as the default title
}) {
  return AppBar(
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.transparent, // For consistent background color
    elevation: 1, // Add a subtle shadow
    title: Text( // Always display text title now
      title!, // Use ! because we know it's not null (either provided or default)
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    centerTitle: false, // Center the title by default
    actions: [
      GestureDetector(
        onTap: () {
          Navigator.pushReplacementNamed(context, profileRoute);
        },
        child: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 20,
            backgroundImage: AssetImage(profileImagePath),
            onBackgroundImageError: (exception, stackTrace) {
              // Fallback to a default icon if profile image asset fails
              print('Error loading profile image: $exception');
            },
          ),
        ),
      ),
    ],
  );
}