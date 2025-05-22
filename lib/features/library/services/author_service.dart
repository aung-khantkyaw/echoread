import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getAuthorDetail(String? authorId) async {
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

  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final authorsSnapshot = await _firestore
          .collection('authors')
          .orderBy('author_name')
          .get();

      // For each author, fetch number of books from 'book' collection
      final authorsWithBookCount = await Future.wait(authorsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final authorId = doc.id;

        // Query books collection to count books for this author
        final booksSnapshot = await _firestore
            .collection('books')
            .where('author_id', isEqualTo: authorId)
            .get();

        final bookCount = booksSnapshot.size;

        return {
          'id': authorId,
          'name': data['author_name']?.toString() ?? 'Unknown',
          'book_count': bookCount,
        };
      }).toList());

      return authorsWithBookCount;
    } catch (e, stackTrace) {
      log('Unexpected error in getAuthors: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<Map<String, dynamic>?> getAuthorById(String authorId) async {
    try {
      // Get author document
      final authorDoc = await _firestore.collection('authors').doc(authorId).get();

      if (!authorDoc.exists) {
        return null;
      }

      final authorData = authorDoc.data();
      final authorName = authorData?['author_name']?.toString() ?? 'Unknown';
      final authorProfileImg = authorData?['profile_img']?.toString() ?? '';
      final authorBio = authorData?['bio']?.toString() ?? '';

      // Get all books by this author
      final booksSnapshot = await _firestore
          .collection('books')
          .where('author_id', isEqualTo: authorId)
          .get();

      final books = booksSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'book_name': data['book_name']?.toString() ?? 'Untitled',
          'book_description': data['book_description']?.toString() ?? '',
          'book_img': data['book_img']?.toString() ?? '',
        };
      }).toList();

      return {
        'author': {
          'id': authorId,
          'name': authorName,
          'profile_img': authorProfileImg,
          'bio': authorBio,
        },
        'books': books,
      };
    } catch (e, stackTrace) {
      log('Unexpected error in getAuthorById: $e', stackTrace: stackTrace);
      return null;
    }
  }
}