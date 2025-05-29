import 'dart:async';
import 'package:flutter/material.dart';
import 'package:echoread/core/widgets/book_card.dart';

import '../../../../l10n/app_localizations.dart';

class HomeContentPage extends StatefulWidget {
  final List<Map<String, dynamic>> allBooks;

  const HomeContentPage({super.key, required this.allBooks});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  late List<Map<String, dynamic>> _books;
  final PageController _pageController = PageController(viewportFraction: 0.9);
  late Timer _autoSlideTimer;
  int _currentPage = 0;

  final List<String> _heroImages = [
    'assets/image/img_one.png',
    'assets/image/img_two.jpeg',
    'assets/image/img_three.jpeg',
  ];

  @override
  void initState() {
    super.initState();
    _books = List<Map<String, dynamic>>.from(widget.allBooks);

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % _heroImages.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoSlideTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero image slider
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _heroImages.length,
              itemBuilder: (context, index) => _buildHeroImage(_heroImages[index]),
            ),
          ),

          const SizedBox(height: 30),

          // Section title
          Padding(
            padding: EdgeInsets.only(left: 6.0, bottom: 16.0),
            child: Text(
              loc.latest_books,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          // Book list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
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

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildHeroImage(String imageUrl) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }
}
