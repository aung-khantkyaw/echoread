import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'package:echoread/core/utils/cloudinary_file_upload.dart';
import 'package:echoread/core/utils/func.dart';

import '../../../core/utils/cloudinary_file_delete.dart';

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
      final existingBooks = await _firestore
          .collection('books')
          .where('book_name', isEqualTo: bookName)
          .get();

      if (existingBooks.docs.isNotEmpty) {
        throw Exception('A book with the name "$bookName" already exists.');
      }

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

        log('Chunk upload URLs: $chunks');

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

  Future<void> updateBook({
    required String bookId,
    required String bookName,
    required String bookDescription,
    required String authorId,
    File? newBookImage,
    String? existingBookImageUrl,
    File? newEbookFile,
    String? existingEbookUrl,
    required List<File> newAudioFiles,
    required List<String> existingAudioUrlsToKeep,
    required List<String> originalAudioUrls,
    String? originalEbookUrl,
    String? originalBookImgUrl,
  }) async {
    try {
      final cloudinaryUploader = CloudinaryFileUpload();
      String? finalBookImgUrl = existingBookImageUrl;
      List<String> finalEbookUrls = [];
      List<String> finalAudioUrls = List.from(existingAudioUrlsToKeep);

      if (newBookImage != null) {
        log('Updating book image: new image selected');
        final uploadedUrl = await cloudinaryUploader.uploadImageToCloudinary(
          newBookImage,
          'book_cover',
        );
        if (uploadedUrl == null) throw Exception('New book image upload failed');
        finalBookImgUrl = uploadedUrl;

        if (originalBookImgUrl != null && originalBookImgUrl.isNotEmpty) {
          log('Deleting old book image: $originalBookImgUrl');
          await _deleteFileFromCloudinary(originalBookImgUrl);
        }
      } else if (existingBookImageUrl == null && originalBookImgUrl != null) {
        log('Book image removed by user: $originalBookImgUrl');
        if (originalBookImgUrl.isNotEmpty) {
          await _deleteFileFromCloudinary(originalBookImgUrl);
        }
        finalBookImgUrl = null;
      } else {
        finalBookImgUrl = originalBookImgUrl;
      }

      if (newEbookFile != null) {
        log('Updating ebook: new ebook file selected');
        final ebookSize = newEbookFile.lengthSync();
        if (ebookSize > 10 * 1024 * 1024) {
          log('New eBook is too large, splitting by pages...');
          final chunks = await compute(splitPdfByPageWrapper, {
            'filePath': newEbookFile.path,
            'pagesPerChunk': 50,
          });
          finalEbookUrls.addAll(chunks);
        } else {
          log('Uploading new eBook directly...');
          final uploadedPath = await cloudinaryUploader.uploadPdfToCloudinary(newEbookFile, 'ebooks');
          if (uploadedPath == null) throw Exception('New ebook upload failed');
          finalEbookUrls.add(uploadedPath);
        }

        if (originalEbookUrl != null && originalEbookUrl.isNotEmpty) {
          log('Deleting old ebook: $originalEbookUrl');
          await _deleteFileFromCloudinary(originalEbookUrl);
        }
      } else if (existingEbookUrl == null && originalEbookUrl != null) {
        log('Ebook file removed by user: $originalEbookUrl');
        if (originalEbookUrl.isNotEmpty) {
          await _deleteFileFromCloudinary(originalEbookUrl);
        }
      } else {
        if (originalEbookUrl != null) {
          finalEbookUrls.add(originalEbookUrl);
        }
      }


      final List<List<String>> newAudioUploadResults = await Future.wait(
        newAudioFiles.map((file) async {
          final audioSizeMB = file.lengthSync() / (1024 * 1024);
          if (audioSizeMB > 100) {
            log('New audio file ${file.path} is too large, splitting...');
            return await compute(splitAudioByDurationWrapper, {
              'filePath': file.path,
              'durationMinutes': 60,
            });
          } else {
            log('Uploading new audio file ${file.path} directly...');
            final uploadedPath = await cloudinaryUploader.uploadAudioToCloudinary(file, 'book_audios');
            if (uploadedPath == null) throw Exception('New audio file upload failed for ${file.path}');
            return [uploadedPath];
          }
        }),
      );
      finalAudioUrls.addAll(newAudioUploadResults.expand((x) => x).toList());

      for (var originalUrl in originalAudioUrls) {
        if (!existingAudioUrlsToKeep.contains(originalUrl)) {
          log('Deleting removed audio file: $originalUrl');
          await _deleteFileFromCloudinary(originalUrl);
        }
      }

      await _firestore.collection('books').doc(bookId).update({
        'book_name': bookName,
        'book_description': bookDescription,
        'author_id': authorId,
        'book_img': finalBookImgUrl,
        'ebook_urls': finalEbookUrls,
        'audio_urls': finalAudioUrls,
        'updated_at': FieldValue.serverTimestamp(),
      });

      log('Book "$bookId" updated successfully');
    } catch (e, stackTrace) {
      log('Failed to update book: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> deleteBook(String bookId) async {
    log('Attempting to delete book with ID: $bookId - START');
    try {
      final bookDoc = await _firestore.collection('books').doc(bookId).get();

      if (!bookDoc.exists) {
        log('Book with ID: $bookId not found in Firestore.');
        return;
      }

      final data = bookDoc.data();
      if (data == null) {
        log('Book data is null for ID: $bookId');
        throw Exception('Book data is null.');
      }

      final String? bookImgUrl = data['book_img'] as String?;
      final List<String> ebookUrls = List<String>.from(data['ebook_urls'] ?? []);
      final List<String> audioUrls = List<String>.from(data['audio_urls'] ?? []);

      log('Deleting associated Cloudinary files for book ID: $bookId');

      if (bookImgUrl != null && bookImgUrl.isNotEmpty) {
        await _deleteFileFromCloudinary(bookImgUrl);
      } else {
        log('No book image URL found for deletion.');
      }

      if (ebookUrls.isNotEmpty) {
        for (final url in ebookUrls) {
          await _deleteFileFromCloudinary(url);
        }
      } else {
        log('No ebook URLs found for deletion.');
      }

      if (audioUrls.isNotEmpty) {
        for (final url in audioUrls) {
          await _deleteFileFromCloudinary(url);
        }
      } else {
        log('No audio URLs found for deletion.');
      }

      log('Deleting book record from Firestore for ID: $bookId');
      await _firestore.collection('books').doc(bookId).delete();

      log('✅ Book "$bookId" and its associated files deleted successfully!');
    } catch (e, stackTrace) {
      log('❌ Error deleting book "$bookId": $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _deleteFileFromCloudinary(String filePathOrUrl) async {
    if (filePathOrUrl.isEmpty) {
      log('Skipping deletion: filePathOrUrl is empty');
      return;
    }

    try {
      String publicIdWithExtension;
      String resourceType;

      if (filePathOrUrl.startsWith('http')) {
        final uri = Uri.parse(filePathOrUrl);
        final segments = uri.pathSegments;

        final uploadIndex = segments.indexOf('upload');
        if (uploadIndex == -1 || uploadIndex + 1 >= segments.length) {
          log('Invalid Cloudinary URL format for deletion, missing public ID: $filePathOrUrl');
          return;
        }

        publicIdWithExtension = segments.sublist(uploadIndex + 1).join('/');
      } else {
        publicIdWithExtension = filePathOrUrl;
      }

      final lastDot = publicIdWithExtension.lastIndexOf('.');
      final publicId = lastDot != -1
          ? publicIdWithExtension.substring(0, lastDot)
          : publicIdWithExtension;

      if (publicIdWithExtension.contains('book_cover') || publicIdWithExtension.endsWith('.jpg')) {
        resourceType = 'image';
      } else if (publicIdWithExtension.contains('ebooks') || publicIdWithExtension.endsWith('.pdf')) {
        resourceType = 'raw';
      } else if (publicIdWithExtension.contains('book_audios') || publicIdWithExtension.endsWith('.mp3')) {
        resourceType = 'video';
      } else {
        resourceType = 'raw';
      }

      log('Attempting Cloudinary deletion: "$publicId" (resourceType: "$resourceType")');

      final cloudinaryDeleter = CloudinaryFileDelete();
      final success = await cloudinaryDeleter.deleteCloudinaryFile(publicId, resourceType: resourceType);

      if (success) {
        log('Successfully deleted "$publicId" from Cloudinary.');
      } else {
        log('Failed to delete "$publicId" from Cloudinary.');
      }
    } catch (e, stackTrace) {
      log('Error in _deleteFileFromCloudinary: $e', stackTrace: stackTrace);
    }
  }

}