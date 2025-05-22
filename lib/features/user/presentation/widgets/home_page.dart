import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/book_card.dart';
import 'package:echoread/core/widgets/recommended_book_card.dart';

class HomeContentPage extends StatefulWidget {
  final List<Map<String, dynamic>> allBooks; // Receive all books from parent

  const HomeContentPage({super.key, required this.allBooks});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  late List<Map<String, dynamic>> _books;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _books = List<Map<String, dynamic>>.from(widget.allBooks);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Recommended for you',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // Recommended Books (Horizontal Scroll)
            SizedBox(
              height: 270,
              child: Scrollbar(
                controller: _scrollController, // You need to define this controller
                thumbVisibility: true, // Always show the scrollbar thumb
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: _books.length,
                  itemBuilder: (context, index) {
                    final book = _books[index];
                    return buildRecommendedBookCard(
                      imageUrl: book['book_img'],
                      title: book['book_name'] ?? '',
                      author: book['author']?['author_name'] ?? '',
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Currently Reading Section
            const Padding(
              padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: Text(
                'Currently Reading',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            // List of Currently Reading Books (Vertical List)
            ListView.builder(
              shrinkWrap: true, // Important for ListView inside SingleChildScrollView
              physics: const NeverScrollableScrollPhysics(), // Prevent inner scrolling
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
            const SizedBox(height: 20), // Space before bottom nav bar
          ],
        )
    );
  }


}