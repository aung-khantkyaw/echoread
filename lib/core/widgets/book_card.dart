import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import '../config/cloudinary_config.dart';

Widget bookCard({
  required String imageUrl,
  required String title,
  required String subtitle,
  required String author,
  required String bookId, // <-- Needed for navigation
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: () {
      Navigator.pushReplacementNamed(
        context,
        '/book-detail', // <-- Update this route based on your route setup
        arguments: {'bookId': bookId},
      );
    },
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.grey[200],
              image: DecorationImage(
                image: NetworkImage(
                  CloudinaryConfig.baseUrl(imageUrl, MediaType.image),
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4.0),
                Text(
                  author,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
