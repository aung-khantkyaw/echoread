import 'package:flutter/material.dart';

class SystemWidgets {
  static Widget sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 30, left: 16, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    ),
  );

  static Widget sectionItem(
      BuildContext context,
      String label, {
        String? value,
        VoidCallback? onTap,
      }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: value != null
          ? Text(
        value,
        style: const TextStyle(fontSize: 16),
      )
          : const Icon(Icons.arrow_forward_ios, size: 18),
      onTap: onTap ?? () => showSnackBar(context, '$label tapped'),
    );
  }
}

void showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}
