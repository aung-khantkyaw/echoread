import 'package:flutter/material.dart';

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
                    decoration: const InputDecoration(
                      hintText: 'Search for authors',
                      prefixIcon: Icon(Icons.search, color: Colors.black54),
                      border: InputBorder.none, // Keep this to avoid default underline
                      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Explore authors',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _authors.isEmpty
                      ? const Center(
                    child: Text(
                      'No authors found',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  )
                      : ListView.builder(
                    itemCount: _authors.length,
                    itemBuilder: (context, index) {
                      final author = _authors[index];
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 6, horizontal: 8),
                        leading: CircleAvatar(
                          radius: 28,
                          // backgroundImage: NetworkImage(author['image'] ?? ''),
                          backgroundColor: Colors.blueGrey[100],
                          child: Icon(Icons.person, color: Colors.black54),
                        ),
                        title: Text(
                          author['name'] ?? 'Unknown Author',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text(
                          author['book_count'] == 0
                              ? 'No books'
                              : '${author['book_count']} ${author['book_count'] == 1 ? 'book' : 'books'}',
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
