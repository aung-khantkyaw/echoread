import 'package:flutter/material.dart';

Widget buildFilePicker({
  required String label,
  required String? filePath,
  required VoidCallback onPressed,
  String placeholder = 'No file selected',
  bool isUploading = false, // <-- Add this
}) {
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
                  isUploading
                      ? 'Uploading...' // <-- Show this if uploading
                      : (filePath != null ? filePath.split('/').last : placeholder),
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onPressed,
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
