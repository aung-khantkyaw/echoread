import 'package:echoread/features/admin/presentation/widgets/author_add_page.dart';
import 'package:echoread/features/admin/presentation/widgets/author_update_page.dart';
import 'package:flutter/material.dart';
import 'package:echoread/l10n/app_localizations.dart';

import 'package:echoread/core/config/cloudinary_config.dart';

import '../../services/author_manage_service.dart';

class AuthorManage extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const AuthorManage({super.key, required this.authorsList});

  @override
  State<AuthorManage> createState() => _AuthorManageState();
}

class _AuthorManageState extends State<AuthorManage> {
  late List<Map<String, dynamic>> _authors;
  late List<Map<String, dynamic>> _allAuthors;

  final _authorService = AuthorManageService();

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

  void _goToAddAuthor() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthorAddPage(authorsList: widget.authorsList),
      ),
    );

    // Fetch latest authors from DB/API
    if (result != null) {
      final freshAuthors = await _authorService.getAuthors();
      setState(() {
        _authors = freshAuthors;
        _allAuthors = freshAuthors;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    return SafeArea(
      child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: _goToAddAuthor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF8C2D),
                    foregroundColor: const Color(0xFF4B1E0A),
                    minimumSize: const Size.fromHeight(45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'AncizarSerifBold',
                    ),
                  ),
                  child: Text(locale.add_author),
                ),
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
                      :ListView.builder(
                    itemCount: _authors.length,
                      itemBuilder: (context, index) {
                        final author = _authors[index];
                        final bookCount = author['book_count'] ?? 0;

                        return Dismissible(
                          key: Key(author['id'].toString()),
                          background: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.only(left: 20),
                            alignment: Alignment.centerLeft,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            color: Colors.blue,
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.edit, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              return await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(locale.confirm_delete),
                                  content: Text(locale.delete_author),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(locale.cancel)),
                                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(locale.delete)),
                                  ],
                                ),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthorUpdatePage(
                                    authorId: author['id'],
                                    authorName: author['name'],
                                    profileImg: author['profile_img'],
                                  ),
                                ),
                              );
                              return false;
                            }
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.startToEnd) {
                              await _authorService.deleteAuthor(author['id']);
                              final freshAuthors = await _authorService.getAuthors();
                              setState(() {
                                _authors = freshAuthors;
                                _allAuthors = freshAuthors;
                              });
                            }
                          },
                          child: Column(
                            children: [
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                                ),
                                subtitle: Text(
                                  bookCount == 0 ? locale.no_books : '$bookCount ${bookCount == 1 ? locale.book : locale.books}',
                                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                                ),
                                onTap: () => Navigator.pushReplacementNamed(
                                  context,
                                  '/author-profile',
                                  arguments: {'authorId': author['id']},
                                ),
                              ),
                              const Divider(height: 1),
                            ],
                          ),
                        );
                      }
                  )
                ),
              ],
            ),
          ),
      ),
    );
  }
}
