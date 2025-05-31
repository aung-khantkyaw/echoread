import 'package:flutter/material.dart';

Widget buildFilePicker({
  required String label,
  required String? filePath, // This is for locally picked files
  required VoidCallback onPressed,
  String? networkUrl, // Added networkUrl parameter, optional
  String placeholder = 'No file selected',
  bool isUploading = false,
}) {
  String displayText;

  if (isUploading) {
    displayText = 'Uploading...';
  } else if (filePath != null) {
    // Display the name of the locally picked file
    displayText = filePath.split('/').last;
  } else if (networkUrl != null && networkUrl.isNotEmpty) {
    // Display the name from the network URL
    // Extracting filename from URL, e.g., "http://example.com/files/document.pdf" -> "document.pdf"
    displayText = Uri.parse(networkUrl).pathSegments.last;
  } else {
    displayText = placeholder;
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                displayText,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                overflow: TextOverflow.ellipsis, // Prevent text overflow
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: isUploading ? null : onPressed, // Disable button when uploading
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA44D),
              foregroundColor: const Color(0xFF4B1E0A),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontFamily: 'AncizarSerifBold',
              ),
            ),
            child: const Text('Browse'),
          ),
        ],
      ),
    ],
  );
}