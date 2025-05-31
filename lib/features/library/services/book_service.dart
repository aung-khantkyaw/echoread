import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final booksSnapshot = await _firestore.collection('books').orderBy('created_at', descending: true).get();

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

  Future<List<Map<String, dynamic>>> getFinishBooksByUserId(String userId) async {
    try {
      final finishBooksSnapshot = await _firestore
          .collection('reading_status')
          .where('userId', isEqualTo: userId)
          .where('isComplete', isEqualTo: true)
          .get();

      if (finishBooksSnapshot.docs.isEmpty) {
        return [];
      }

      final futures = finishBooksSnapshot.docs.map((savedDoc) async {
        final data = savedDoc.data();
        final bookId = data['bookId'];

        if (bookId == null || bookId is! String) {
          log("Skipping document ${savedDoc.id} because 'book_id' is null or not a String");
          return null;
        }

        final bookDoc = await _firestore.collection('books').doc(bookId).get();
        if (!bookDoc.exists) {
          return null;
        }
        final bookData = bookDoc.data()!;

        final authorId = bookData['author_id'] as String?;
        Map<String, dynamic>? authorData;
        if (authorId != null) {
          final authorDoc = await _firestore.collection('authors').doc(authorId).get();
          authorData = authorDoc.data();
        }

        return {
          'finish_book_id': savedDoc.id,
          'finish_at': data['endDate'],
          'book': {
            'id': bookDoc.id,
            ...bookData,
            if (authorData != null) 'author': authorData,
          },
        };
      }).toList();

      final finishBooks = await Future.wait(futures);
      log(finishBooks.toString());
      return finishBooks.whereType<Map<String, dynamic>>().toList();
    } catch (e, stackTrace) {
      log('Error getting saved books for user $userId: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getSavedBooksByUserId(String userId) async {
    try {
      final savedBooksSnapshot = await _firestore
          .collection('saved_books')
          .where('user_id', isEqualTo: userId)
          .get();

      if (savedBooksSnapshot.docs.isEmpty) {
        return [];
      }

      final futures = savedBooksSnapshot.docs.map((savedDoc) async {
        final data = savedDoc.data();
        final bookId = data['book_id'] as String;

        final bookDoc = await _firestore.collection('books').doc(bookId).get();
        if (!bookDoc.exists) {
          return null;
        }
        final bookData = bookDoc.data()!;

        final authorId = bookData['author_id'] as String?;
        Map<String, dynamic>? authorData;
        if (authorId != null) {
          final authorDoc = await _firestore.collection('authors').doc(authorId).get();
          authorData = authorDoc.data();
        }

        return {
          'saved_book_id': savedDoc.id,
          'saved_at': data['saved_at'],
          'book': {
            'id': bookDoc.id,
            ...bookData,
            if (authorData != null) 'author': authorData,
          },
        };
      }).toList();

      final savedBooks = await Future.wait(futures);

      log(savedBooks.toString());
      return savedBooks.whereType<Map<String, dynamic>>().toList();
    } catch (e, stackTrace) {
      log('Error getting saved books for user $userId: $e', stackTrace: stackTrace);
      return [];
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
      final querySnapshot = await _firestore
          .collection('saved_books')
          .where('user_id', isEqualTo: userId)
          .where('book_id', isEqualTo: bookId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.delete();
        log('Book $bookId removed from saved books for user $userId');
      } else {
        log('Book $bookId not found in saved books for user $userId');
      }
    } catch (e) {
      throw Exception('Failed to remove book from saved list: $e');
    }
  }

}