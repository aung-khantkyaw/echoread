import 'package:flutter/material.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

import 'package:echoread/core/widgets/book_card.dart';
import 'package:echoread/core/widgets/custom_gif_loading.dart';

import 'package:echoread/l10n/app_localizations.dart';

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
    final locale = AppLocalizations.of(context)!;

    if (isLoading) {
      return const GifLoader();
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
                  backgroundColor: Colors.blueGrey[100],
                  backgroundImage: (profileImg != null && profileImg.toString().isNotEmpty)
                      ? NetworkImage(CloudinaryConfig.baseUrl(profileImg, MediaType.image))
                      : null,
                  child: (profileImg == null || profileImg.toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.black54)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  authorDetail?['name'] ?? 'Unknown',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  authorBooks.isEmpty
                      ? locale.no_books
                      : '${authorBooks.length} ${authorBooks.length == 1} ? locale.book : locale.books}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          ...[
            if (authorBooks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                child: Text(
                  locale.books,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
          ],
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
