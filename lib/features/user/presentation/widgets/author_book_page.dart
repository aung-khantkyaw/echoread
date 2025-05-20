import 'package:flutter/material.dart';
import 'package:echoread/features/user/presentation/screens/book_detail_screen.dart'; // Import the new screen

class AuthorBookPage extends StatelessWidget {
  final List<Map<String, dynamic>> booksList; // Receive books list from parent

  const AuthorBookPage({super.key, required this.booksList});

  // This method will now navigate to the book detail page
  void _navigateToBookDetail(BuildContext context, String bookId, String bookName) {
    Navigator.pushNamed(
      context,
      BookDetailScreen.routeName, // Use the defined routeName
      arguments: bookId, // Pass only the bookId as a String argument
    );
  }

  @override
  Widget build(BuildContext context) {
    if (booksList.isEmpty) {
      return const Center(
        child: Text('No books available for this author.'),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.7,
      ),
      itemCount: booksList.length,
      itemBuilder: (context, index) {
        final book = booksList[index];
        final bookId = book['id'] ?? '';
        final bookName = book['book_name'] ?? 'Unknown Book';
        final bookImg = book['book_img']?.toString().isNotEmpty == true
            ? book['book_img']
            : 'assets/icon/app_icon.png';

        return GestureDetector(
          onTap: () => _navigateToBookDetail(context, bookId, bookName),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Image.network(
                    bookImg,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/icon/app_icon.png',
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    bookName,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}