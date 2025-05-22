import 'package:flutter/material.dart';
import 'package:echoread/core/config/cloudinary_config.dart';
import 'package:echoread/core/widgets/pdf_view_screen.dart';
import '../../services/book_service.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  Future<Map<String, dynamic>?> fetchBookDetail() async {
    final BookService bookService = BookService();
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

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('Failed to load book details.'));
        }

        final bookDetail = snapshot.data!;
        final authorDetail = bookDetail['author'] ?? {};

        final coverImage = bookDetail['book_img'] as String?;
        final imageUrl = (coverImage != null && coverImage.isNotEmpty)
            ? CloudinaryConfig.baseUrl(coverImage, MediaType.image)
            : null;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 150,
                      height: 225,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                        image: imageUrl != null
                            ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                            : null,
                        color: Colors.grey[200],
                      ),
                      child: imageUrl == null
                          ? const Icon(Icons.book, size: 80, color: Colors.grey)
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      bookDetail['book_name'] ?? 'Untitled',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      authorDetail['author_name'] ?? 'Unknown Author',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'What\'s it about?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  bookDetail['book_description'] ?? 'No description available.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        final ebookUrl = bookDetail['ebook_url'];
                        if (ebookUrl != null && ebookUrl.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewScreen(publicId: ebookUrl),
                            ),
                          );
                        }
                      },

                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Download Ebook'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        final audioUrl = bookDetail['audio_url'];
                        if (audioUrl != null && audioUrl.isNotEmpty) {
                          // open or download audio
                        }
                      },
                      icon: const Icon(Icons.audiotrack),
                      label: const Text('Download Audio'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Save or bookmark functionality
                      },
                      icon: const Icon(Icons.bookmark),
                      label: const Text('Save Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        minimumSize: const Size.fromHeight(45),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
