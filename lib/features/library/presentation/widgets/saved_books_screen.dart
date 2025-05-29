import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';

import '../../services/book_service.dart';

class SavedBooksScreen extends StatefulWidget {
  const SavedBooksScreen({super.key});
  static const String routeName = '/saved-books';

  @override
  State<SavedBooksScreen> createState() => _SavedBooksScreenState();
}

class _SavedBooksScreenState extends State<SavedBooksScreen> {
  final BookService _bookService = BookService();

  String? _currentUserId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _savedBooks = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndSavedBooks();
  }

  Future<void> _loadUserAndSavedBooks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _currentUserId = user.uid;
    } else {
      log('User not logged in');
      _currentUserId = 'T7WSeYtDek1G6GqQa1KK'; // fallback if needed
    }
    await _fetchSavedBooks();
  }

  Future<void> _fetchSavedBooks() async {
    if (_currentUserId == null) return;
    setState(() {
      _isLoading = true;
    });
    final savedBooks = await _bookService.getSavedBooksByUserId(_currentUserId!);
    setState(() {
      _savedBooks = savedBooks;
      _isLoading = false;
    });
  }

  Future<void> _unsaveBook(String savedBookId, String bookId) async {
    try {
      // Remove saved book via BookService logic
      // Your existing removeSavedBookForUser method is a bit different (uses subcollection)
      // Here, savedBookId is the document ID in saved_books collection, so delete directly:
      await FirebaseFirestore.instance.collection('saved_books').doc(savedBookId).delete();

      showSnackBar(context, 'Book unsaved successfully!', type: SnackBarType.success);
      // Refresh list
      await _fetchSavedBooks();
    } catch (e) {
      log('Error unsaving book: $e');
      showSnackBar(context, 'Failed to unsave book.', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
        title: 'Saved Books',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedBooks.isEmpty
          ? const Center(
        child: Text(
          'No saved books found.',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'AncizarSerifBold',
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _savedBooks.length,
        itemBuilder: (context, index) {
          final savedBook = _savedBooks[index];
          final savedBookId = savedBook['saved_book_id'] as String? ?? '';
          final savedAtTimestamp = savedBook['saved_at'] as Timestamp?;
          final book = savedBook['book'] as Map<String, dynamic>?;

          final bookId = book?['id'] ?? '';
          final bookName = book?['book_name'] ?? 'Unknown Book';
          final bookImg = book?['book_img'] ?? '';
          final author = book?['author'] as Map<String, dynamic>?;

          final authorName = author != null ? author['author_name'] ?? 'Unknown Author' : 'No Author';

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: bookImg.isNotEmpty
                  ? Image.network(
                bookImg,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.book),
              )
                  : const Icon(Icons.book, size: 50),
              title: Text(bookName),
              subtitle: Text('Author: $authorName\n'
                  'Saved on: ${savedAtTimestamp != null ? savedAtTimestamp.toDate().toLocal().toString().split(' ')[0] : 'Unknown'}'),
              isThreeLine: true,
              trailing: IconButton(
                icon: const Icon(Icons.bookmark_remove, color: Colors.red),
                tooltip: 'Unsave Book',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Confirm Unsave'),
                        content: Text('Remove "$bookName" from your saved books?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Unsave'),
                          ),
                        ],
                      );
                    },
                  );
                  if (confirm == true) {
                    await _unsaveBook(savedBookId, bookId);
                  }
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
