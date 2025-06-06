import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final booksSnapshot = await _firestore.collection('books').get();

      final books = booksSnapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();

      final authorIds = books
          .map((book) => book['author_id'])
          .toSet()
          .toList();

      final authorsSnapshot = await _firestore
          .collection('authors')
          .where(FieldPath.documentId, whereIn: authorIds)
          .get();

      final authorsMap = {
        for (var doc in authorsSnapshot.docs) doc.id: doc.data()
      };

      return books.map((book) => {
        ...book,
        'author': authorsMap[book['author_id']],
      }).toList();

    } catch (e, stackTrace) {
      log('Unexpected error in getBooks: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getLatestThreeBooks() async {
    try {
      final booksSnapshot = await _firestore
          .collection('books')
          .orderBy('created_at', descending: true)
          .limit(3)
          .get();

      final books = booksSnapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();

      final authorIds = books
          .map((book) => book['author_id'])
          .whereType<String>()
          .toSet()
          .toList();

      Map<String, dynamic> authorsMap = {};

      if (authorIds.isNotEmpty) {
        final authorsSnapshot = await _firestore
            .collection('authors')
            .where(FieldPath.documentId, whereIn: authorIds)
            .get();

        authorsMap = {
          for (var doc in authorsSnapshot.docs) doc.id: doc.data()
        };
      }

      return books.map((book) => {
        ...book,
        'author': authorsMap[book['author_id']] ?? {},
      }).toList();
    } catch (e, stackTrace) {
      log('Unexpected error in getLatestThreeBooks: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCurrentlyReadingBookByUserId(String userId) async {
    try {

      final readingStatusSnapshot = await _firestore
          .collection('reading_status')
          .where('userId', isEqualTo: userId)
          .where('isComplete', isEqualTo: false)
          .get();

      for (var doc in readingStatusSnapshot.docs) {
        log('Reading Status: ${doc.data()}');
      }

      final bookIds = readingStatusSnapshot.docs
          .map((doc) => doc['bookId'] as String)
          .toSet()
          .toList();

      if (bookIds.isEmpty) return [];

      // Step 2: Get books from 'books' collection using the bookIds
      final booksSnapshot = await _firestore
          .collection('books')
          .where(FieldPath.documentId, whereIn: bookIds)
          .get();

      final books = booksSnapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();

      // Step 3: Extract unique authorIds
      final authorIds = books
          .map((book) => book['author_id'])
          .toSet()
          .toList();

      // Step 4: Get author details
      final authorsSnapshot = await _firestore
          .collection('authors')
          .where(FieldPath.documentId, whereIn: authorIds)
          .get();

      final authorsMap = {
        for (var doc in authorsSnapshot.docs) doc.id: doc.data()
      };

      // Step 5: Combine book and author data
      return books.map((book) => {
        ...book,
        'author': authorsMap[book['author_id']],
      }).toList();

    } catch (e, stackTrace) {
      log('Unexpected error in getCurrentlyReadingBookByUserId: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<int> booksCount() async{
    try {
      final querySnapshot = await _firestore
          .collection('books')
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      log('Error counting saved books: $e');
      return 0;
    }
  }

  Future<int> saveBooksCountByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('saved_books')
          .where('user_id', isEqualTo: userId)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      log('Error counting saved books: $e');
      return 0;
    }
  }

  Future<int> finishBooksCountByUserId(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reading_status')
          .where('userId', isEqualTo: userId)
          .where('isComplete', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      log('Error counting saved books: $e');
      return 0; 
    }
  }
}