import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:echoread/core/widgets/item_manage_card.dart';
import '../../services/author_manage_service.dart';

class AuthorManage extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const AuthorManage({super.key, required this.authorsList});

  @override
  State<AuthorManage> createState() => _AuthorManageState();
}

class _AuthorManageState extends State<AuthorManage> {
  final TextEditingController _controller = TextEditingController();
  final AuthorManageService _service = AuthorManageService();

  late List<Map<String, dynamic>> _authors;

  bool _isEditing = false;
  String? _editingId;

  @override
  void initState() {
    super.initState();
    _authors = List<Map<String, dynamic>>.from(widget.authorsList);
  }

  Future<void> _addAuthor() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    await _service.createAuthor(name);

    setState(() {
      _authors.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
      });
      _controller.clear();
    });

    log('Created Author: $name');
  }

  void _startEdit(String id) {
    final author = _authors.firstWhere((a) => a['id'] == id, orElse: () => {});
    if (author.isEmpty) return;

    setState(() {
      _isEditing = true;
      _editingId = id;
      _controller.text = author['name'] ?? '';
    });
  }

  Future<void> _updateAuthor() async {
    final name = _controller.text.trim();
    if (name.isEmpty || _editingId == null) return;

    await _service.updateAuthor(_editingId!, name);

    final index = _authors.indexWhere((a) => a['id'] == _editingId);
    if (index == -1) return;

    setState(() {
      _authors[index]['name'] = name;
      _isEditing = false;
      _editingId = null;
      _controller.clear();
    });

    log('Updated Author: $name');
  }

  Future<void> _deleteAuthor(String id) async {
    final author = _authors.firstWhere((a) => a['id'] == id, orElse: () => {});
    if (author.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete "${author['name']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _service.deleteAuthor(id);

    setState(() {
      _authors.removeWhere((a) => a['id'] == id);

      if (_isEditing && _editingId == id) {
        _isEditing = false;
        _editingId = null;
        _controller.clear();
      }

      log('Deleted Author with id: $id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter author name',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(7),
                          bottomRight: Radius.circular(7),
                        ),
                      ),
                      elevation: 0,
                      backgroundColor: Colors.white,
                    ),
                    onPressed: _isEditing ? _updateAuthor : _addAuthor,
                    child: Text(_isEditing ? 'Update' : 'Add'),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: _authors.isEmpty
              ? const Center(child: Text('No authors available.'))
              : ListView.builder(
            itemCount: _authors.length,
            itemBuilder: (context, index) {
              final author = _authors[index];
              return HorizontalCard(
                title: author['name'] ?? 'Unknown Author',
                onEdit: () => _startEdit(author['id']),
                onDelete: () => _deleteAuthor(author['id']),
              );
            },
          ),
        ),
      ],
    );
  }
}
