import 'package:echoread/core/widgets/book_card.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';

import '../../services/author_service.dart';

class AuthorProfileScreen extends StatefulWidget {
  final String authorId;
  const AuthorProfileScreen({super.key, required this.authorId});

  @override
  State<AuthorProfileScreen> createState() => _AuthorProfileScreenState();
}

class _AuthorProfileScreenState extends State<AuthorProfileScreen> {
  final AuthorService _authorManageService = AuthorService();

  Map<String, dynamic>? authorDetail;
  List<Map<String, dynamic>> authorBooks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final data = await _authorManageService.getAuthorById(widget.authorId);

    if (data != null) {
      setState(() {
        authorDetail = data['author'];
        authorBooks = List<Map<String, dynamic>>.from(data['books'] ?? []);
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final profileImg = authorDetail?['profile_img'] ??
        'https://via.placeholder.com/120x120/F0D9C8/A55C42?text=Author';

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profileImg),
                ),
                const SizedBox(height: 16),
                Text(
                  authorDetail?['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Author',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 16.0),
            child: Text(
              'Books',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: authorBooks.length,
            itemBuilder: (context, index) {
              final book = authorBooks[index];
              return bookCard(
                context: context,
                bookId: book['id'] ?? '',
                imageUrl: book['book_img'] ?? '',
                title: book['book_name'] ?? '',
                subtitle: book['book_description'] ?? '',
                author: authorDetail?['name'] ?? 'Unknown',
              );

            },
          ),
        ],
    );
  }
}
