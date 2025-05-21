import 'dart:io';

import 'package:flutter/material.dart';

Widget buildImagePicker({required File? filePath, required VoidCallback onPressed,}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: onPressed, // Trigger image picker on tap
        borderRadius: BorderRadius.circular(8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: Container(
            height: 160,
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            alignment: Alignment.center,
            child: filePath == null
                ? Text(
              'Upload Book Image',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                filePath,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}