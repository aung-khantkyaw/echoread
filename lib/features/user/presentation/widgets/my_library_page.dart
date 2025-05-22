import 'package:flutter/material.dart';

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

  final List<Map<String, dynamic>> libraryCategories = [
    {
      'icon': Icons.bookmark_border,
      'title': 'Saved',
      'count': '15 items',
      'onTap' : '/'
    },
    {
      'icon': Icons.collections_bookmark_outlined,
      'title': 'Collections',
      'count': '32 collections',
      'onTap' : '/'
    },
    {
      'icon': Icons.check_circle_outline,
      'title': 'Finished',
      'count': '1 item',
      'onTap' : '/'
    },
    {
      'icon': Icons.download_outlined,
      'title': 'Downloads',
      'count': '32 item',
      'onTap' : '/download-history'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 8.0, bottom: 20.0),
              child: Text(
                'My Library',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),

            Column(
              children: libraryCategories.map((category) {
                return libraryCategoryItem(
                  icon: category['icon'],
                  title: category['title'],
                  count: category['count'],
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

            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'My History',
                style: TextStyle(
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