import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/cloudinary_file_upload.dart';

class AccountManageService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<String?> changeUserEmail({
    required String newEmail,
    required String currentPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return "No user logged in.";
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(cred);

      await user.updateEmail(newEmail);

      await user.sendEmailVerification();

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return 'An unexpected error occurred.';
    }
  }
}