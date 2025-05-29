import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:echoread/core/utils/cloudinary_file_upload.dart';
import 'package:echoread/core/utils/func.dart';

class BookManageService {
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

      log('Uploading book image');
      final bookImgPath = await cloudinaryUploader.uploadImageToCloudinary(bookImage, 'book_cover');
      if (bookImgPath == null) throw Exception('Book image upload failed.');

      final List<String> ebookPaths = [];
      final ebookSize = ebookFile.lengthSync();

      if (ebookSize > 10 * 1024 * 1024) {
        log('eBook is too large, splitting by pages...');

        final stopwatch = Stopwatch()..start();
        final chunks = await compute(splitPdfByPageWrapper, {
          'filePath': ebookFile.path,
          'pagesPerChunk': 50,
        });
        log('PDF split in ${stopwatch.elapsed}');

        log(chunks.toString());

        ebookPaths.addAll(chunks);

      } else {
        log('Uploading eBook');
        final path = await cloudinaryUploader.uploadPdfToCloudinary(ebookFile, 'ebooks');
        if (path == null) throw Exception('eBook upload failed');
        ebookPaths.add(path);
      }

      log('Uploading ${audioFiles.length} audio file(s)');

      final futures = audioFiles.map((file) async {
        final audioSizeMB = file.lengthSync() / (1024 * 1024);

        if (audioSizeMB > 100) {
          log('${file.path} is too large ($audioSizeMB MB), splitting...');

          final parts = await compute(splitAudioByDurationWrapper, {
            'filePath': file.path,
            'durationMinutes': 60,
          });

          log(parts.toString());
          return parts;

        } else {
          log('${file.path} is under 100MB, uploading directly...');
          final uploadedPath = await cloudinaryUploader.uploadAudioToCloudinary(file, 'book_audios');
          if (uploadedPath == null) throw Exception('Audio upload failed for ${file.path}');
          return [uploadedPath];
        }
      });

      final List<List<String>> results = await Future.wait(futures);
      final audioPaths = results.expand((x) => x).toList();

      if (audioPaths.isEmpty || ebookPaths.isEmpty) {
        if (audioPaths.isEmpty) {
          throw Exception('Audio upload returned empty paths');
        }
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