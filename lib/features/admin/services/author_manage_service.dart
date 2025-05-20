import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorManageService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all authors, ordered by author_name
  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('authors').orderBy('author_name').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Include the document ID
          'name': data['author_name'] ?? 'Unknown', // Map 'author_name' from Firestore to 'name' key
        };
      }).toList();
    } catch (e) {
      log('Unexpected error getting authors: $e');
      return []; // Return empty list on error
    }
  }

  // Create a new author
  Future<void> createAuthor(String authorName) async {
    try {
      // Use add() for Firestore to automatically generate a document ID
      await _firestore.collection('authors').add({
        'author_name': authorName, // Store author name in 'author_name' field
        'created_at': FieldValue.serverTimestamp(), // Use server timestamp
      });
      log('Author "$authorName" created successfully');
    } catch (e) {
      log('Failed to create author: $e');
    }
  }

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
      final DocumentSnapshot doc = await _firestore.collection('authors').doc(authorId).get();
      if (doc.exists) {
        // Return the document data including the ID
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id, // Include the document ID
          'name': data['author_name'] ?? 'Unknown', // Map 'author_name' from Firestore to 'name' key
        };
      }
      log('Author with ID $authorId not found.');
      return null; // Return null if document does not exist
    } catch (e) {
      log('Error getting author detail for ID $authorId: $e');
      return null; // Return null on error
    }
  }

  // Update an existing author's name
  Future<void> updateAuthor(String authorId, String authorName) async {
    try {
      // Update the document with the given ID
      await _firestore.collection('authors').doc(authorId).update({
        'author_name': authorName, // Update the 'author_name' field
        'updated_at': FieldValue.serverTimestamp(), // Update the timestamp
      });
      log('Author "$authorId" updated to "$authorName"');
    } catch (e) {
      log('Failed to update author: $e');
    }
  }

  // Delete an author by ID
  Future<void> deleteAuthor(String authorId) async {
    try {
      // Delete the document with the given ID
      await _firestore.collection('authors').doc(authorId).delete();
      log('Author deleted: $authorId');
    } catch (e) {
      log('Error deleting author: $e');
    }
  }
}
