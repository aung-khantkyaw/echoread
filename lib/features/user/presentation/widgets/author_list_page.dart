import 'package:flutter/material.dart';
import 'package:echoread/features/user/presentation/screens/author_book_screen.dart'; // Import the new screen

class AuthorListPage extends StatelessWidget {
  final List<Map<String, dynamic>> authorsList; // Receive author list from parent

  const AuthorListPage({super.key, required this.authorsList});

  // This method will now navigate to the AuthorBookScreen
  void _navigateToAuthorBooks(BuildContext context, String authorId, String authorName) {
    Navigator.pushNamed(
      context,
      AuthorBookScreen.routeName, // Use the defined routeName
      arguments: { // Pass arguments as a Map
        'authorId': authorId,
        'authorName': authorName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a message if the author list is empty
    if (authorsList.isEmpty) {
      return const Center(
        child: Text('No authors available.'),
      );
    }

    // Display the list of authors using ListView.builder
    return ListView.builder(
      itemCount: authorsList.length,
      itemBuilder: (context, index) {
        final author = authorsList[index];
        // Assuming author['id'] exists and is the document ID from Firestore
        final authorId = author['id'] ?? '';
        final authorName = author['name'] ?? 'Unknown Author'; // Assuming 'name' field for author's name

        return GestureDetector( // Make the list item tappable
          onTap: () => _navigateToAuthorBooks(context, authorId, authorName), // Call navigate method on tap
          child: Card( // Use a Card for each list item
            margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4), // Adjust margin
            elevation: 1, // Add slight shadow
            shape: RoundedRectangleBorder( // Rounded corners and border
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Colors.grey, width: 1), // Add border
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding inside card
              child: Text( // Display the author's name
                authorName,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        );
      },
    );
  }
}