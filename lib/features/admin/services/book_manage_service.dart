import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:echoread/core/utils/cloudinary_file_upload.dart';

import '../../../core/utils/func.dart';

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
    log('Create Book - START');

    try {
      final cloudinaryUploader = CloudinaryFileUpload();

      // Upload book image
      log('Uploading book image');
      final bookImgPath = await cloudinaryUploader.uploadImageToCloudinary(bookImage, 'book_cover');

      if (bookImgPath == null) throw Exception('Book image upload failed.');

      // Upload eBook
      final List<String> ebookPaths = [];
      final ebookSize = ebookFile.lengthSync();

      if (ebookSize > 10 * 1024 * 1024) {
        log('eBook is too large, splitting by pages...');

        final chunks = await splitPdfByPage(ebookFile, 10); // Each chunk ~10 pages

        for (final chunk in chunks) {
          final path = await cloudinaryUploader.uploadPdfToCloudinary(chunk, 'ebooks');
          if (path == null) throw Exception('Failed to upload ebook chunk');
          ebookPaths.add(path);
          chunk.deleteSync(); // cleanup
        }
      } else {
        final path = await cloudinaryUploader.uploadPdfToCloudinary(ebookFile, 'ebooks');
        if (path == null) throw Exception('eBook upload failed');
        ebookPaths.add(path);
      }

      // Upload audio files
      final List<String> audioPaths = [];

      log('Uploading ${audioFiles.length} audio file(s)');
      for (final audioFile in audioFiles) {
        final sizeInMB = audioFile.lengthSync() / (1024 * 1024);

        List<File> audioChunks = [];

        if (sizeInMB > 100) {
          log('Audio file too big (${sizeInMB.toStringAsFixed(2)} MB), splitting...');
          audioChunks = await splitAudioByDuration(audioFile, 600); // every 10 mins
        } else {
          audioChunks = [audioFile];
        }

        for (final chunk in audioChunks) {
          final path = await cloudinaryUploader.uploadAudioToCloudinary(chunk, 'book_audio');
          if (path == null) throw Exception('Audio upload failed');
          audioPaths.add(path);
          chunk.deleteSync(); // Clean up chunk files
        }
      }

      if (audioPaths.isEmpty || ebookPaths.isEmpty) {
        throw Exception('Upload returned empty paths');
      }

      // Save to Firestore
      final bookData = {
        'book_name': bookName,
        'book_description': bookDescription,
        'ebook_urls': ebookPaths,
        'audio_urls': audioPaths,
        'book_img': bookImgPath,
        'author_id': authorId,
        'created_at': FieldValue.serverTimestamp(),
      };

      log('Creating book in Firestore: $bookData');
      await _firestore.collection('books').add(bookData);

      log('Book creation successful');
    } catch (e, stackTrace) {
      log('Error in createBook: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

}