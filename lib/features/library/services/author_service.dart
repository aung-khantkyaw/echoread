import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a single author's details by ID
  // Accepts String? to handle potential null authorId from book data
  Future<Map<String, dynamic>?> getAuthorDetail(String? authorId) async {
    // Check if authorId is null or empty before attempting to fetch
    if (authorId == null || authorId.isEmpty) {
      log('Author ID is null or empty.');
      return null;
    }
    try {
      // Get the document by its ID
      final DocumentSnapshot doc = await _firestore.collection('authors').doc(
          authorId).get();
      if (doc.exists) {
        // Return the document data including the ID
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          // Include the document ID
          'name': data['author_name'] ?? 'Unknown',
          // Map 'author_name' from Firestore to 'name' key
        };
      }
      log('Author with ID $authorId not found.');
      return null; // Return null if document does not exist
    } catch (e) {
      log('Error getting author detail for ID $authorId: $e');
      return null; // Return null on error
    }
  }

}