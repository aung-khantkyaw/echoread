import 'package:flutter/material.dart';
import 'package:echoread/l10n/app_localizations.dart';

import '../../../../core/config/cloudinary_config.dart';

class ExplorerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const ExplorerScreen({super.key, required this.authorsList});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen> {
  late List<Map<String, dynamic>> _authors;
  late List<Map<String, dynamic>> _allAuthors;

  @override
  void initState() {
    super.initState();
    _allAuthors = List<Map<String, dynamic>>.from(widget.authorsList);
    _authors = List<Map<String, dynamic>>.from(widget.authorsList);
  }

  void _filterAuthors(String query) {
    setState(() {
      _authors = _allAuthors
          .where((author) =>
          author['name']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // White background
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300), // Light grey border
                  ),
                  child: TextField(
                    onChanged: _filterAuthors,
                    decoration: InputDecoration(
                      hintText: locale.search_authors_hint,
                      prefixIcon: const Icon(Icons.search, color: Colors.black54),
                      border: InputBorder.none, // Avoid default underline
                      contentPadding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  locale.explore_authors,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _authors.isEmpty
                      ? Center(
                    child: Text(
                      locale.no_authors_found,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _authors.length,
                    itemBuilder: (context, index) {
                      final author = _authors[index];
                      final bookCount = author['book_count'] ?? 0;
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blueGrey[100],
                          backgroundImage: (author['profile_img'] != null && author['profile_img'].toString().isNotEmpty)
                              ? NetworkImage(CloudinaryConfig.baseUrl(author['profile_img'], MediaType.image))
                              : null,
                          child: (author['profile_img'] == null || author['profile_img'].toString().isEmpty)
                              ? const Icon(Icons.person, color: Colors.black54)
                              : null,
                        ),
                        title: Text(
                          author['name'] ?? locale.unknown_author,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          bookCount == 0
                              ? locale.no_books
                              : '$bookCount ${bookCount == 1 ? locale.book : locale.books}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                        onTap: () => Navigator.pushReplacementNamed(
                          context,
                          '/author-profile',
                          arguments: {'authorId': author['id']},
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
