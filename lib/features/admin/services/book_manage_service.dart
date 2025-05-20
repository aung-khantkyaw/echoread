import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookManageService{
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

}