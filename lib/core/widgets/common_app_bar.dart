import 'package:flutter/material.dart';

PreferredSizeWidget commonAppBar({
  required BuildContext context,
  required String profileRoute,
  required String profileImagePath,
}) {
  return AppBar(
    title: Text('EchoRead'),
    actions: [
      IconButton(
        onPressed: () {
          Navigator.pushReplacementNamed(context, profileRoute);
        },
        icon: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 2),
            image: DecorationImage(
              image: AssetImage(profileImagePath),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    ],
  );
}
