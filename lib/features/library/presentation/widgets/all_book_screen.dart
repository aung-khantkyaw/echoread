import 'package:flutter/material.dart';

import 'package:echoread/l10n/app_localizations.dart';
import 'package:echoread/core/widgets/book_card.dart';

import '../../../../core/widgets/app_bar.dart';
import '../../services/book_service.dart';

class AllBookScreen extends StatefulWidget {

  const AllBookScreen({
    super.key,
  });

  static const String routeName = '/all-books';

  @override
  State<AllBookScreen> createState() => _AllBookScreenState();
}

class _AllBookScreenState extends State<AllBookScreen> {
  final _bookService = BookService();
  List<Map<String, dynamic>> _books = [];
  List<Map<String, dynamic>> _allBooks = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBooks();
    _refreshBooks();
  }

  Future<void> _loadBooks() async {
    _allBooks = await _bookService.getBooks();
    _books = List<Map<String, dynamic>>.from(_allBooks);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshBooks() async {
    final freshBooks = await _bookService.getBooks();
    setState(() {
      _books = freshBooks;
    });
  }

  void _filterBooks(String query) {
    setState(() {
      _books = _allBooks
          .where((book) {
        final name = (book['book_name'] ?? '').toString().toLowerCase();
        return name.contains(query.toLowerCase());
      })
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
        title: locale.books,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: TextField(
                onChanged: _filterBooks,
                decoration: InputDecoration(
                  hintText: locale.search_books_hint,
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _books.isEmpty
                  ? Center(
                child: Text(
                  locale.no_books_found,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
              )
                  : ListView.builder(
                itemCount: _books.length,
                itemBuilder: (context, index) {
                  final book = _books[index];
                  return bookCard(
                    context: context,
                    bookId: book['id']?.toString() ?? '',
                    imageUrl: book['book_img'] ?? '',
                    title: book['book_name'] ?? '',
                    subtitle: book['book_description'] ?? '',
                    author: book['author']?['author_name'] ?? '',
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

}
