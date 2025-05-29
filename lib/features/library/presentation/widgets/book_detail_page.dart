import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:echoread/core/config/cloudinary_config.dart';
import 'package:echoread/features/library/presentation/widgets/audio_player_page.dart';
import 'package:echoread/features/library/presentation/widgets/pdf_view_page.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:echoread/features/library/services/book_service.dart';

class BookDetailsScreen extends StatefulWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  State<BookDetailsScreen> createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  final BookService _bookService = BookService();
  late Future<Map<String, dynamic>?> _bookDetailFuture;
  bool _isBookSaved = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _bookDetailFuture = _bookService.getBookDetail(widget.bookId);
    _checkIfBookIsSaved();
    log(_isBookSaved.toString());
  }

  Future<void> _checkIfBookIsSaved() async {
    if (_currentUser == null) return;

    try {
      final isSaved = await _bookService.isBookSavedByUser(_currentUser!.uid, widget.bookId);
      setState(() {
        _isBookSaved = isSaved;
        log(_isBookSaved.toString());
      });
      log(_isBookSaved.toString());
    } catch (e) {
      debugPrint("Error checking if book is saved: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _bookDetailFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Failed to load book details.')),
          );
        }

        final book = snapshot.data!;
        final author = book['author'] ?? {};
        final cover = book['book_img'] as String?;
        final imageUrl = (cover?.isNotEmpty ?? false)
            ? CloudinaryConfig.baseUrl(cover!, MediaType.image)
            : null;

        return Scaffold(
          backgroundColor: const Color(0xFFFFF4ED),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                              ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                              : null,
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 3)),
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
                const Text("What's it about?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(book['book_description'] ?? 'No description available.',
                    style: const TextStyle(fontSize: 16, height: 1.5)),
                const SizedBox(height: 30),

                // --- Ebook Button ---
                ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Read Ebook"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C2D),
                    foregroundColor: const Color(0xFF4B1E0A),
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () {
                    final parts = book['ebook_urls'];
                    if (parts is List && parts.every((e) => e is String)) {
                      final urls = parts.cast<String>().map(
                            (id) => CloudinaryConfig.baseUrl(id, MediaType.ebook),
                      ).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PdfMergedViewScreen(
                            parts: urls,
                            title: book['book_name'] ?? 'Ebook',
                          ),
                        ),
                      );
                    } else {
                      showSnackBar(context, 'Invalid ebook parts list', type: SnackBarType.error);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // --- Audio Button ---
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
                    if (audioParts is List && audioParts.every((e) => e is String)) {
                      final urls = audioParts.cast<String>().map(
                            (id) => CloudinaryConfig.baseUrl(id, MediaType.audio),
                      ).toList();

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AudioPlayScreen(
                            title: book['book_name'] ?? '',
                            author: author['author_name'] ?? '',
                            coverImageUrl: imageUrl ?? '',
                            audioUrls: urls,
                          ),
                        ),
                      );
                    } else {
                      showSnackBar(context, 'Invalid audio parts list', type: SnackBarType.error);
                    }
                  },
                ),
                const SizedBox(height: 10),

                // --- Save/Unsave Button ---
                _isBookSaved
                    ? ElevatedButton.icon(
                  icon: const Icon(Icons.bookmark_remove),
                  label: const Text("Unsave Book"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[800],
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () async {
                    if (_currentUser == null) {
                      showSnackBar(context, "You need to log in to unsave this book",
                          type: SnackBarType.error);
                      return;
                    }

                    try {
                      await _bookService.removeSavedBookForUser(_currentUser!.uid, widget.bookId);
                      setState(() => _isBookSaved = false);
                      showSnackBar(context, "Book unsaved successfully!", type: SnackBarType.success);
                    } catch (e) {
                      showSnackBar(context, "Failed to unsave book. $e", type: SnackBarType.error);
                    }
                  },
                )
                    : ElevatedButton.icon(
                  icon: const Icon(Icons.bookmark),
                  label: const Text("Save Book"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFE2C4),
                    foregroundColor: const Color(0xFF4B1E0A),
                    minimumSize: const Size.fromHeight(45),
                  ),
                  onPressed: () async {
                    if (_currentUser == null) {
                      showSnackBar(context, "You need to log in to save this book",
                          type: SnackBarType.error);
                      return;
                    }

                    try {
                      await _bookService.saveBookForUser(_currentUser!.uid, widget.bookId);
                      setState(() => _isBookSaved = true);
                      showSnackBar(context, "Book saved successfully!", type: SnackBarType.success);
                    } catch (e) {
                      showSnackBar(context, "Failed to save book. $e", type: SnackBarType.error);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
