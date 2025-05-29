import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/l10n/app_localizations.dart';

import 'package:echoread/core/widgets/book_card.dart';
import 'package:echoread/core/widgets/library_category_item.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';

import '../../services/book_service.dart';

class MyLibraryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> currentReadingBooks;

  const MyLibraryScreen({super.key, required this.currentReadingBooks});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  late List<Map<String, dynamic>> _books;
  int _allBooksCount = 0;
  int _saveBooksCount = 0;
  int _finishBookCount = 0;
  final BookService _bookService = BookService();

  @override
  void initState() {
    super.initState();
    _books = List<Map<String, dynamic>>.from(widget.currentReadingBooks);
    _loadSavedBooksCount();
  }

  Future<void> _loadSavedBooksCount() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final bookCount = await _bookService.booksCount();
    final saveCount = await _bookService.saveBooksCountByUserId(userId);
    final finishCount = await _bookService.finishBooksCountByUserId(userId);
    setState(() {
      _allBooksCount = bookCount;
      _saveBooksCount = saveCount;
      _finishBookCount = finishCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> libraryCategories = [
      {
        'icon': Icons.book_outlined,
        'title': loc.books,
        'count': _allBooksCount,
        'onTap': '/all-books'
      },
      {
        'icon': Icons.bookmark_border,
        'title': loc.saved,
        'count': _saveBooksCount,
        'onTap': '/saved-books'
      },
      {
        'icon': Icons.check_circle_outline,
        'title': loc.finished,
        'count': _finishBookCount,
        'onTap': '/finish-books'
      },
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: libraryCategories.map((category) {
              return libraryCategoryItem(
                icon: category['icon'],
                title: category['title'],
                count: '${category['count']} ${category['count'] == 0 || category['count'] == 1 ? loc.item : loc.items}',
                onTap: () {
                  final route = category['onTap'];
                  if (route is String && route.isNotEmpty) {
                    Navigator.pushNamed(context, route);
                  } else {
                    showSnackBar(context, 'No route defined for this category');
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Text(
              loc.currently_reading,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _books.length,
            itemBuilder: (context, index) {
              final book = _books[index];
              return bookCard(
                context: context,
                bookId: book['id'] ?? '',
                imageUrl: book['book_img'] ?? '',
                title: book['book_name'] ?? '',
                subtitle: book['book_description'] ?? '',
                author: book['author']?['author_name'] ?? '',
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
