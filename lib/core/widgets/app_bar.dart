import 'package:flutter/material.dart';

PreferredSizeWidget commonAppBar({
  required BuildContext context,
  String? title = 'EchoRead',
}) {
  return AppBar(
    backgroundColor: const Color(0xFFF56B00),
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    title: Text(
      title!,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'CinzelBold',
        color: Color(0xFF4B1E0A)
      ),
    ),
    centerTitle: false,
  );
}
