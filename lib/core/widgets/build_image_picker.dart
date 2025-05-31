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
  bool isUploading = false,
}) {
  Widget contentChild;

  if (isUploading) {
    contentChild = const CircularProgressIndicator();
  } else if (filePath != null) {
    contentChild = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.file(
        filePath,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      ),
    );
  } else if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
    contentChild = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        networkImageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        // Optional: Add a placeholder while loading network image
        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) => Center(
          child: Icon(Icons.broken_image, color: Colors.grey[400]),
        ),
      ),
    );
  } else {
    contentChild = Text(
      placeholderText,
      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      InkWell(
        onTap: isUploading ? null : onPressed, // Disable tap when uploading
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
            child: contentChild, // Use the renamed child
          ),
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}