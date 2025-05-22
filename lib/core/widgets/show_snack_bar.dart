import 'package:flutter/material.dart';

enum SnackBarType { success, error }

void showSnackBar(BuildContext context, String message, {SnackBarType type = SnackBarType.success}) {
  final color = (type == SnackBarType.success) ? Colors.green : Colors.red;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}
