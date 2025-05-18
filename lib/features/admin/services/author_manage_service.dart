import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

class AuthorManageService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final QuerySnapshot snapshot = await _firestore.collection('authors').orderBy('author_name').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['author_name'] ?? 'Unknown',
        };
      }).toList();
    } catch (e) {
      log('Unexpected error: $e');
      return [];
    }
  }

  Future<void> createAuthor(String authorName) async {
    try {
      await _firestore.collection('authors').add({
        'author_name': authorName,
        'created_at': FieldValue.serverTimestamp(),
      });
      log('Author "$authorName" created successfully');
    } catch (e) {
      log('Failed to create author: $e');
    }
  }

  Future<void> updateAuthor(String authorId, String authorName) async {
    try {
      await _firestore.collection('authors').doc(authorId).update({
        'author_name': authorName,
        'updated_at': FieldValue.serverTimestamp(),
      });
      log('Author "$authorId" updated to "$authorName"');
    } catch (e) {
      log('Failed to update author: $e');
    }
  }

  Future<void> deleteAuthor(String authorId) async {
    try {
      await _firestore.collection('authors').doc(authorId).delete();
      log('Author deleted: $authorId');
    } catch (e) {
      log('Error deleting author: $e');
    }
  }
}