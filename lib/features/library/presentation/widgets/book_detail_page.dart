import 'package:flutter/material.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

import 'package:echoread/features/library/presentation/widgets/audio_player_page.dart';
import 'package:echoread/features/library/presentation/widgets/pdf_view_page.dart';

import 'package:echoread/features/library/services/book_service.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  Future<Map<String, dynamic>?> fetchBookDetail() async {
    final bookService = BookService();
    return await bookService.getBookDetail(bookId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchBookDetail(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const Center(child: Text('Failed to load book details.'));
        }

        final book = snapshot.data!;
        final author = book['author'] ?? {};
        final cover = book['book_img'] as String?;
        final imageUrl = (cover != null && cover.isNotEmpty)
            ? CloudinaryConfig.baseUrl(cover, MediaType.image)
            : null;

        return Scaffold(
            backgroundColor: const Color(0xFFFFF4ED),
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 225,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[200],
                          image: imageUrl != null
                              ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: imageUrl == null
                            ? const Icon(Icons.book, size: 80, color: Colors.grey)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        book['book_name'] ?? 'Untitled',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        author['author_name'] ?? 'Unknown Author',
                        style: const TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  "What's it about?",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  book['book_description'] ?? 'No description available.',
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 30),
                Column(
                  children: [
                    ElevatedButton.icon(
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text("Read Ebook"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C2D),
                          foregroundColor: const Color(0xFF4B1E0A),
                          minimumSize: const Size.fromHeight(45),
                        ),
                        onPressed: () {
                          final ebookParts = book['ebook_urls'];
                          if (ebookParts != null &&
                              ebookParts is List &&
                              ebookParts.every((e) => e is String)) {

                            // publicId list ကို full URL list အဖြစ်ပြောင်းမယ်
                            final List<String> urls = ebookParts.map((publicId) {
                              return CloudinaryConfig.baseUrl(publicId, MediaType.ebook);
                            }).toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PdfMergedViewScreen(
                                  parts: urls, // full URL list ပေးလိုက်တာ
                                  title: book['book_name'] ?? 'Ebook',
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid ebook parts list')),
                            );
                          }
                        }
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.audiotrack),
                      label: const Text("Play Audio"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFA44D),
                        foregroundColor: const Color(0xFF4B1E0A),
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () {
                        final audioParts = book['audio_urls'];
                        if (audioParts != null &&
                            audioParts is List &&
                            audioParts.every((e) => e is String) &&
                            audioParts.isNotEmpty) {

                          // publicId list ကို full URL list အဖြစ်ပြောင်းမယ်
                          final List<String> urls = audioParts.map((audioPart) {
                            return CloudinaryConfig.baseUrl(audioPart, MediaType.audio);
                          }).toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AudioPlayScreen(
                                title: book['book_name'] ?? '',
                                author: author['author_name'] ?? '',
                                coverImageUrl: imageUrl ?? '',
                                audioUrls: urls,  // list of URLs
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Invalid audio parts list')),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.bookmark),
                      label: const Text("Save Book"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFE2C4),
                        foregroundColor: const Color(0xFF4B1E0A),
                        minimumSize: const Size.fromHeight(45),
                      ),
                      onPressed: () {
                        // Save/bookmark functionality
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
