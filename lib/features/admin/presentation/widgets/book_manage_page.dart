import 'package:flutter/material.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

import 'book_add_page.dart';

import 'package:echoread/features/library/presentation/widgets/pdf_view_page.dart';

class BookManage extends StatefulWidget {
  final List<Map<String, dynamic>> booksList;
  final List<Map<String, dynamic>> authorsList;

  const BookManage({
    super.key,
    required this.booksList,
    required this.authorsList,
  });

  @override
  State<BookManage> createState() => _BookManageState();
}

class _BookManageState extends State<BookManage> {
  void _goToAddBook() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BookAddForm(
          authorsList: widget.authorsList,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _goToAddBook,
          child: const Text('Add Book'),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: widget.booksList.length,
            itemBuilder: (context, index) {
              final book = widget.booksList[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (book['book_img'] != null && book['book_img'].toString().isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            CloudinaryConfig.baseUrl(book['book_img'], MediaType.image),
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Text('Failed to load image'),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text(
                        book['book_name'] ?? 'No name',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        book['book_description'] ?? 'No description',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PdfViewScreen(publicId: book['ebook_url'], title: book['book_name'],),
                            ),
                          )},
                        child: const Text("Go"),
                      ),
                      Text('Ebook URL: ${book['ebook_url'] ?? 'N/A'}'),
                      Text('Audio URL: ${book['audio_url'] ?? 'N/A'}'),
                      Text('Author ID: ${book['author_name'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}
