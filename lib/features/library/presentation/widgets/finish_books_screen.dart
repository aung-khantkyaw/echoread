import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/app_bar.dart';

import '../../services/book_service.dart';

class FinishBooksScreen extends StatefulWidget {
  const FinishBooksScreen({super.key});
  static const String routeName = '/finish-books';

  @override
  State<FinishBooksScreen> createState() => _FinishBooksScreenState();
}

class _FinishBooksScreenState extends State<FinishBooksScreen> {
  final BookService _bookService = BookService();

  String? _currentUserId;
  bool _isLoading = true;
  List<Map<String, dynamic>> _finishBooks = [];

  @override
  void initState() {
    super.initState();
    _loadUserAndfinishBooks();
  }

  Future<void> _loadUserAndfinishBooks() async {
    _currentUserId = FirebaseAuth.instance.currentUser!.uid;
    await _fetchfinishBooks();
  }

  Future<void> _fetchfinishBooks() async {
    if (_currentUserId == null) return;
    setState(() {
      _isLoading = true;
    });
    final finishBooks = await _bookService.getFinishBooksByUserId(_currentUserId!);
    setState(() {
      _finishBooks = finishBooks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
        title: 'Finish Books',
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _finishBooks.isEmpty
          ? const Center(
        child: Text(
          'No finish books found.',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'AncizarSerifBold',
            fontWeight: FontWeight.w500,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _finishBooks.length,
        itemBuilder: (context, index) {
          final finishBook = _finishBooks[index];
          final finishBookId = finishBook['finish_book_id'] as String? ?? '';
          final finishAtTimestamp = finishBook['finish_at'] as Timestamp?;
          final book = finishBook['book'] as Map<String, dynamic>?;

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
                  'Finish on: ${finishAtTimestamp != null ? finishAtTimestamp.toDate().toLocal().toString().split(' ')[0] : 'Unknown'}'),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
