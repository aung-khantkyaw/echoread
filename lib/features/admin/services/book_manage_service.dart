import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echoread/core/config/cloudinary_file_upload.dart';

class BookManageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getBooks() async {
    try {
      final booksSnapshot = await _firestore.collection('books').get();

      final books = booksSnapshot.docs.map((doc) =>
      {
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

      return books.map((book) =>
      {
        ...book,
        'author': authorsMap[book['author_id']],
      }).toList();
    } catch (e, stackTrace) {
      log('Unexpected error in getBooks: $e', stackTrace: stackTrace);
      return [];
    }
  }

  Future<void> createBook({
    required File bookImage,
    required File ebookFile,
    required List<File> audioFiles,
    required String bookName,
    required String bookDescription,
    required String authorId,
  }) async {
    try {
      final cloudinaryUploader = CloudinaryFileUpload();

      final bookImgPath = await cloudinaryUploader.uploadImageToCloudinary(bookImage, 'book_cover');

      final ebookPath = await cloudinaryUploader.uploadPdfToCloudinary(ebookFile, 'ebooks');

      final List<String> audioPaths = [];
      for (final audioFile in audioFiles) {
        final audioPath =
        await cloudinaryUploader.uploadAudioToCloudinary(
            audioFile, 'book_audio');
        if (audioPath == null) throw Exception('Audio upload failed');
        audioPaths.add(audioPath);
      }

      if (bookImgPath == null || ebookPath == null || audioPaths.isEmpty) {
        throw Exception('One or more uploads failed');
      }

      final bookData = {
        'book_name': bookName,
        'book_description': bookDescription,
        'ebook_url': ebookPath,
        'audio_urls': audioPaths,
        'book_img': bookImgPath,
        'author_id': authorId,
        'created_at': FieldValue.serverTimestamp(),
      };

      log('Creating book: $bookData');
      await _firestore.collection('books').add(bookData);
    } catch (e, stackTrace) {
      log('Error in createBook: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}