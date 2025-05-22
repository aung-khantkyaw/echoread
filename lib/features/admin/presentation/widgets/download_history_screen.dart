import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';


class DownloadHistoryScreen extends StatefulWidget {
  const DownloadHistoryScreen({super.key});
  static const String routeName = '/download-history';
  @override
  State<DownloadHistoryScreen> createState() => _DownloadHistoryScreenState();
}

class _DownloadHistoryScreenState extends State<DownloadHistoryScreen> {
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  void _getCurrentUserId() {

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    } else {
      log('User is not logged in.');
      setState(() {
        _currentUserId = 'T7WSeYtDek1G6GqQa1KK';
      });
    }
  }

  Future<void> _deleteDownload(String downloadDocId) async {
    try {
      await FirebaseFirestore.instance
          .collection('downloads')
          .doc(downloadDocId)
          .delete();
      if (!mounted) return;
      showSnackBar(context, 'Download deleted successfully!', type: SnackBarType.success);
    } catch (e) {
      log('Error deleting download: $e');
      showSnackBar(context, 'Failed to delete download.', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Download History'),
          backgroundColor: Colors.blue,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      appBar: commonAppBar(
        context: context,
        title: 'Download History'
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('downloads')
            .where('user_id', isEqualTo: _currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No downloads found.'));
          }

          final downloadDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: downloadDocs.length,
            itemBuilder: (context, index) {
              final downloadDoc = downloadDocs[index];
              final downloadData = downloadDoc.data() as Map<String, dynamic>;
              final bookId = downloadData['book_id'];
              final downloadDocId = downloadDoc.id;

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('books')
                    .doc(bookId)
                    .get(),
                builder: (context, bookSnapshot) {
                  if (bookSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Loading book...'),
                        trailing: CircularProgressIndicator(),
                      ),
                    );
                  }
                  if (bookSnapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Error loading book: ${bookSnapshot.error}'),
                      ),
                    );
                  }
                  if (!bookSnapshot.hasData || !bookSnapshot.data!.exists) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Book not found for ID: $bookId'),
                      ),
                    );
                  }

                  final bookData = bookSnapshot.data!.data() as Map<String, dynamic>;
                  final bookName = bookData['book_name'] ?? 'Unknown Book';
                  final bookImg = bookData['book_img'] ?? '';

                  return Dismissible(
                    key: Key(downloadDocId),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (direction) async {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Confirm Delete"),
                            content: Text("Are you sure you want to delete '$bookName' from downloads?"),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    onDismissed: (direction) {
                      _deleteDownload(downloadDocId);
                    },
                    child: Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: bookImg.isNotEmpty
                            ? Image.network(
                          bookImg,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.book),
                        )
                            : const Icon(Icons.book, size: 50),
                        title: Text(bookName),
                        subtitle: Text(
                          'Downloaded on: ${DateTime.fromMillisecondsSinceEpoch(downloadData['created_at'].millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}',
                        ),

                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}