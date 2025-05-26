import 'package:flutter/material.dart';

import 'package:echoread/l10n/app_localizations.dart';

import 'package:echoread/core/widgets/book_card.dart';
import 'package:echoread/core/widgets/library_category_item.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';

class MyLibraryScreen extends StatefulWidget {
  final List<Map<String, dynamic>> allBooks;

  const MyLibraryScreen({super.key, required this.allBooks});

  @override
  State<MyLibraryScreen> createState() => _MyLibraryScreenState();
}

class _MyLibraryScreenState extends State<MyLibraryScreen> {
  late List<Map<String, dynamic>> _books;

  @override
  void initState() {
    super.initState();
    _books = List<Map<String, dynamic>>.from(widget.allBooks);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> libraryCategories = [
      {
        'icon': Icons.bookmark_border,
        'title': loc.saved,
        'count': '15',
        'onTap': '/'
      },
      {
        'icon': Icons.collections_bookmark_outlined,
        'title': loc.collections,
        'count': '32',
        'onTap': '/'
      },
      {
        'icon': Icons.check_circle_outline,
        'title': loc.finished,
        'count': '1',
        'onTap': '/'
      },
      {
        'icon': Icons.download_outlined,
        'title': loc.downloads,
        'count': '32',
        'onTap': '/download-history'
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
                count: '${category['count']} ${loc.items}',
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
              loc.myHistory,
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
