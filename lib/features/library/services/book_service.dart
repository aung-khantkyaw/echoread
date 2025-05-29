import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final QuerySnapshot result = await _firestore.collection('books').get();
      return result.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('Error getting books: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getBooksByAuthorId(String authorId) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('books')
          .where('author_id', isEqualTo: authorId)
          .get();
      return result.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      log('Error getting books by author ID $authorId: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBookDetail(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (!doc.exists) return null;

      final bookData = doc.data()!;
      final authorId = bookData['author_id'];

      final authorDoc = await _firestore.collection('authors').doc(authorId).get();
      final authorData = authorDoc.data();

      final result = {
        ...bookData,
        'id': doc.id,
        'author': authorData,
      };

      return result;
    } catch (e, stackTrace) {
      log('Unexpected error in getBookDetail: $e', stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> saveBookForUser(String userId, String bookId) async {
    try {
      final existing = await _firestore
          .collection('saved_books')
          .where('user_id', isEqualTo: userId)
          .where('book_id', isEqualTo: bookId)
          .get();

      if (existing.docs.isEmpty) {
        await _firestore.collection('saved_books').add({
          'user_id': userId,
          'book_id': bookId,
          'saved_at': FieldValue.serverTimestamp(),
        });
      } else {
        log('Book already saved.');
      }
    } catch (e) {
      log('Failed to save book: $e');
      rethrow;
    }
  }

  Future<bool> isBookSavedByUser(String userId, String bookId) async {
    try {
      final querySnapshot = await _firestore
          .collection('saved_books')
          .where('user_id', isEqualTo: userId)
          .where('book_id', isEqualTo: bookId)
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking saved book: $e');
      return false;
    }
  }



  Future<void> removeSavedBookForUser(String userId, String bookId) async {
    try {
      // Find the document that matches the bookId to delete it
      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('saved_books')
          .where('bookId', isEqualTo: bookId)
          .limit(1) // Assuming bookId is unique per user's saved list
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        print('Book $bookId removed from saved books for user $userId');
      } else {
        print('Book $bookId not found in saved books for user $userId');
      }
    } catch (e) {
      throw Exception('Failed to remove book from saved list: $e');
    }
  }

}