import 'package:flutter/material.dart';

class BookDetailPage extends StatelessWidget {
  final Map<String, dynamic> bookDetail;
  final Map<String, dynamic>? authorDetail; // This map now contains 'name' key from AuthorManageService

  const BookDetailPage({
    super.key,
    required this.bookDetail,
    this.authorDetail,
  });

  @override
  Widget build(BuildContext context) {
    // Safely extract book details
    final String bookName = bookDetail['book_name'] ?? 'N/A';
    final String bookImg = bookDetail['book_img']?.toString().isNotEmpty == true
        ? bookDetail['book_img']
        : 'assets/icon/app_icon.png'; // Default image if book_img is null or empty
    final String bookDescription = bookDetail['book_description'] ?? 'No description available.';

    // Safely extract author name from authorDetail map, using the 'name' key
    final String authorName = authorDetail?['name'] ?? 'Unknown Author';

    final String ebookUrl = bookDetail['ebook_url'] ?? '';
    final String audioUrl = bookDetail['audio_url'] ?? '';

    return SingleChildScrollView( // Allow content to scroll if it's too long
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Section: Book Image, Name, and Author Name
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect( // Clip image to rounded rectangle
                borderRadius: BorderRadius.circular(8.0),
                child: Image.network(
                  bookImg,
                  width: 120, // Fixed width for the image
                  height: 180, // Fixed height for the image
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/icon/app_icon.png', // Fallback to a default asset image
                      width: 120,
                      height: 180,
                      fit: BoxFit.contain,
                    );
                  },
                ),
              ),
              const SizedBox(width: 16.0), // Spacing between image and text
              Expanded( // Let text take remaining space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 3, // Allow up to 3 lines for long names
                      overflow: TextOverflow.ellipsis, // Add ellipsis if text overflows
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'By $authorName', // Use the correctly extracted authorName
                      style: TextStyle( // Use TextStyle for explicit color
                        fontSize: 16,
                        color: Colors.grey.shade700, // Corrected: Use .shade700
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),

          // Description Section
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            bookDescription,
            style: const TextStyle(fontSize: 15),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 24.0),

          // Buttons Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Space out buttons
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: ebookUrl.isNotEmpty ? () {
                    // TODO: Implement Read Book functionality (e.g., open URL, navigate to reader)
                    debugPrint('Read Book button tapped for: $bookName (Ebook URL: $ebookUrl)');
                    // Example: _launchUrl(ebookUrl);
                  } : null, // Disable button if no ebook URL
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Read Book'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: audioUrl.isNotEmpty ? () {
                    // TODO: Implement Play Book functionality (e.g., open URL, play audio)
                    debugPrint('Play Book button tapped for: $bookName (Audio URL: $audioUrl)');
                    // Example: _launchUrl(audioUrl);
                  } : null, // Disable button if no audio URL
                  icon: const Icon(Icons.headset),
                  label: const Text('Play Book'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0), // Add some space at the bottom
        ],
      ),
    );
  }
}