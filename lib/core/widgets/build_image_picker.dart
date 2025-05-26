import 'dart:io';
import 'package:flutter/material.dart';

Widget buildImagePicker({
  required File? filePath,
  required VoidCallback onPressed,
  String? networkImageUrl,
  String placeholderText = 'Upload Image',
  double height = 160,
  double borderRadius = 8,
  double elevation = 4,
}) {
  Widget child;

  if (filePath != null) {
    child = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        filePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  } else if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
    child = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        networkImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  } else {
    child = Text(
      placeholderText,
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Card(
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}
