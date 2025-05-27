import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/cloudinary_file_upload.dart';

class AuthorManageService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAuthors() async {
    try {
      final authorsSnapshot = await _firestore
          .collection('authors')
          .orderBy('author_name')
          .get();

      final authorsWithBookCount = await Future.wait(authorsSnapshot.docs.map((doc) async {
        final data = doc.data();
        final authorId = doc.id;

        final booksSnapshot = await _firestore
            .collection('books')
            .where('author_id', isEqualTo: authorId)
            .get();

        final bookCount = booksSnapshot.size;

        return {
          'id': authorId,
          'name': data['author_name']?.toString() ?? 'Unknown',
          'book_count': bookCount,
          'profile_img': data['profile_img']?.toString(),
        };
      }).toList());

      return authorsWithBookCount;
    } catch (e, stackTrace) {
      log('Unexpected error in getAuthors: $e', stackTrace: stackTrace);
      return [];
    }
  }


  Future<void> createAuthor({
    required File authorProfile,
    required String authorName,
  }) async {
    try {
      final cloudinaryUploader = CloudinaryFileUpload();

      final authorProfilePath = await cloudinaryUploader.uploadImageToCloudinary(authorProfile, 'author_profile');

      if (authorProfilePath == null) {
        throw Exception('Upload failed');
      }

      final authorData = {
        'author_name': authorName,
        'profile_img': authorProfilePath,
        'created_at': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('authors').add(authorData);
    } catch (e, stackTrace) {
      log('Error in createAuthor: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> updateAuthorWithImageSupport({
    required String authorId,
    required String authorName,
    File? profileImageFile,
    String? existingImageUrl,
  }) async {
    try {
      String? finalImageUrl = existingImageUrl;

      if (profileImageFile != null) {
        final cloudinaryUploader = CloudinaryFileUpload();
        final uploadedUrl = await cloudinaryUploader.uploadImageToCloudinary(
          profileImageFile,
          'author_profile',
        );

        if (uploadedUrl == null) {
          throw Exception('Image upload failed');
        }

        finalImageUrl = uploadedUrl;
      }

      await _firestore.collection('authors').doc(authorId).update({
        'author_name': authorName,
        'profile_img': finalImageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      log('Author "$authorId" updated successfully');
    } catch (e, stackTrace) {
      log('Failed to update author: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteAuthor(String authorId) async {
    try {
      final batch = _firestore.batch();

      final booksSnapshot = await _firestore
          .collection('books')
          .where('author_id', isEqualTo: authorId)
          .get();

      log('Books found for author: ${booksSnapshot.docs.length}');

      for (var doc in booksSnapshot.docs) {
        batch.delete(doc.reference);
      }

      final authorRef = _firestore.collection('authors').doc(authorId);
      batch.delete(authorRef);

      await batch.commit();

      log('Author and their books deleted: $authorId');
    } catch (e) {
      log('Error deleting author and books: $e');
    }
  }

}

