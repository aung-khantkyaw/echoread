import 'package:flutter/material.dart';
import 'book_add_page.dart';

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
        ...widget.booksList.map((book) => ListTile(
          title: Text(book['book_name'] ?? 'No name'),
          subtitle: Text(book['book_description'] ?? 'No description'),
        )),
      ],
    );
  }
}
