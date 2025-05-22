import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registration(String username, String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('users').doc(uid).set({
        'name': username,
        'email': email,
        'profile_img': 'profile/pggchhf3zntmicvhbxns',
        'role': 'user',
        'created_at': DateTime.now().toIso8601String(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) {
        print('Registration error: ${e.code}');
      }
      return e.code;
    }
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;

        await saveLoginInfo(uid, data['name'], data['email'], data['role'], data['profile_img'] ?? '');

        return {
          'user_id': uid,
          'name': data['name'],
          'email': data['email'],
          'role': data['role'],
          'profile_img': data['profile_img'] ?? '',
        };
      } else {
        return null;
      }
    } on FirebaseAuthException catch (e) {
      if (kDebugMode) print('Login error: ${e.code}');
      return null;
    }
    catch (e) {
      log('Unexpected error: $e');
      rethrow;
    }
  }

  Future<String?> forgetPassword(String email) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return 'No user found with this email.';
      }

      await _auth.sendPasswordResetEmail(email: email);
      return 'Password reset email sent to $email';
    } on FirebaseAuthException catch (e) {
      log('FirebaseAuth error: ${e.code} - ${e.message}');
      return 'Firebase error: ${e.message}';
    } catch (e) {
      log('Unexpected error: $e');
      return 'An unexpected error occurred.';
    }
  }

  Future<void> logout(BuildContext context) async {
    await _auth.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'no-current-user',
          message: 'No user is currently logged in.',
        );
      }

      final uid = user.uid;

      await user.delete();

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'deleted': true,
        'deleted_at': DateTime.now().toIso8601String(),
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
    } on FirebaseAuthException catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
      log('FirebaseAuthException: ${e.code}');
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to delete account. Please try again.')),
      );
      log('Unexpected error during account deletion: $e');
    }
  }

  Future<void> saveLoginInfo(String uid, String name, String email, String role, String profileImg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('userId', uid);
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);
    await prefs.setString('userRole', role);
    await prefs.setString('userProfileImg', profileImg);
  }
}
