import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';

import 'package:echoread/l10n/app_localizations.dart';
import 'package:echoread/core/widgets/book_card.dart';

import '../../services/book_manage_service.dart';
import 'book_add_page.dart';
import 'book_update_page.dart';

class BookManage extends StatefulWidget {
  final List<Map<String, dynamic>> booksList;
  final List<Map<String, dynamic>> authorsList;

  const BookManage({
    super.key,
    required this.booksList,
    required this.authorsList,
  });

  @override
  State<BookManage> createState() => _BookManageState();
}

class _BookManageState extends State<BookManage> {
  final _bookService = BookManageService();
  late List<Map<String, dynamic>> _books;
  late List<Map<String, dynamic>> _allBooks;

  @override
  void initState() {
    super.initState();
    _allBooks = List<Map<String, dynamic>>.from(widget.booksList);
    _books = List<Map<String, dynamic>>.from(widget.booksList);
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
      }).toList();
    });
  }

  void _goToAddBook() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookAddForm(authorsList: widget.authorsList),
      ),
    );

    if (result == true) {
      await _refreshBooks();
    }
  }

  void _goToEditBook(Map<String, dynamic> book) async {
    final updated = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookUpdatePage(
          bookData: book,
          authorsList: widget.authorsList
        ),
      ),
    );

    if (updated == true) {
      await _refreshBooks();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return Column(
      children: [
        ElevatedButton(
          onPressed: _goToAddBook,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF8C2D),
            foregroundColor: const Color(0xFF4B1E0A),
            minimumSize: const Size.fromHeight(45),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontFamily: 'AncizarSerifBold',
            ),
          ),
          child: Text(locale.add_book),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white, // White background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300), // Light grey border
          ),
          child: TextField(
            onChanged: _filterBooks,
            decoration: InputDecoration(
              hintText: locale.search_books_hint,
              prefixIcon: const Icon(Icons.search, color: Colors.black54),
              border: InputBorder.none, // Avoid default underline
              contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Expanded(
          child:  _books.isEmpty
              ? Center(
            child: Text(
              locale.no_books_found,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
          )
              :ListView.builder(
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];

              return Dismissible(
                key: Key(book['id'].toString()),
                background: Container(
                  color: Colors.red,
                  padding: const EdgeInsets.only(left: 20),
                  alignment: Alignment.centerLeft,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.blue,
                  padding: const EdgeInsets.only(right: 20),
                  alignment: Alignment.centerRight,
                  child: const Icon(Icons.edit, color: Colors.white),
                ),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    // Confirm delete
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(locale.confirm_delete),
                        content: Text(locale.delete_book_confirm),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: Text(locale.cancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: Text(locale.delete),
                          ),
                        ],
                      ),
                    );
                    return confirmed ?? false;
                  } else if (direction == DismissDirection.endToStart) {
                    // Edit, don't dismiss automatically
                    _goToEditBook(book);
                    return false;
                  }
                  return false;
                },
                onDismissed: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    await _bookService.deleteBook(book['id']);
                    await _refreshBooks();
                    showSnackBar(context, locale.delete_book, type: SnackBarType.success);
                  }
                },
                child: bookCard(
                  context: context,
                  bookId: book['id']?.toString() ?? '',
                  imageUrl: book['book_img'] ?? '',
                  title: book['book_name'] ?? '',
                  subtitle: book['book_description'] ?? '',
                  author: book['author']?['author_name'] ?? '',
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
