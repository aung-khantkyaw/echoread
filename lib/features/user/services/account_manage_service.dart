import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:echoread/core/utils/cloudinary_file_upload.dart';

class AccountManageService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateAccountWithImageSupport({
    required String accountId,
    required String username,
    File? profileImageFile,
    String? existingImageUrl,
  }) async {
    try {
      String? finalImageUrl = existingImageUrl;

      if (profileImageFile != null) {
        final cloudinaryUploader = CloudinaryFileUpload();
        final uploadedUrl = await cloudinaryUploader.uploadImageToCloudinary(
          profileImageFile,
          'profile',
        );

        if (uploadedUrl == null) {
          throw Exception('Image upload failed');
        }

        finalImageUrl = uploadedUrl;
      }

      await _firestore.collection('users').doc(accountId).update({
        'name': username,
        'profile_img': finalImageUrl,
        'updated_at': FieldValue.serverTimestamp(),
      });

      log('User "$accountId" updated successfully');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userProfileImg', finalImageUrl ?? '');
      await prefs.setString('userName', username);

    } catch (e, stackTrace) {
      log('Failed to update author: $e', stackTrace: stackTrace);
      rethrow;
    }
  }
}