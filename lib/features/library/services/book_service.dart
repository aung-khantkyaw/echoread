import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to get all books (optional, for future use)
  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final QuerySnapshot result = await _firestore.collection('books').get();
      return result.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error getting books: $e');
      return [];
    }
  }

  // Method to get books by a specific author ID
  Future<List<Map<String, dynamic>>> getBooksByAuthorId(String authorId) async {
    try {
      final QuerySnapshot result = await _firestore
          .collection('books')
          .where('author_id', isEqualTo: authorId) // Filter by author_id
          .get();
      return result.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
    } catch (e) {
      print('Error getting books by author ID $authorId: $e');
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


}