import 'package:flutter/material.dart';

import '../config/cloudinary_config.dart';

Widget buildRecommendedBookCard({
  required String imageUrl,
  required String title,
  required String author,
}) {
  return Container(
    width: 140, // Width for each card
    margin: const EdgeInsets.only(right: 16.0), // Space between cards
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 120, // Book cover width
          height: 180, // Book cover height
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(38),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(
                CloudinaryConfig.baseUrl(imageUrl, MediaType.image),
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}