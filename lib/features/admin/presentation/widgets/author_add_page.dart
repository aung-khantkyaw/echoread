import 'dart:io';
import 'package:flutter/material.dart';
import 'package:echoread/core/widgets/build_image_picker.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:echoread/core/utils/media_picker_helper.dart';
import 'package:echoread/features/admin/services/author_manage_service.dart';

class AuthorAddPage extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const AuthorAddPage({super.key, required this.authorsList});

  @override
  State<AuthorAddPage> createState() => _AuthorAddPageState();
}

class _AuthorAddPageState extends State<AuthorAddPage> {
  final _formKey = GlobalKey<FormState>();

  late List<Map<String, dynamic>> _authors;
  late List<Map<String, dynamic>> _allAuthors;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  File? _pickedImage;

  final _authorService = AuthorManageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _allAuthors = List<Map<String, dynamic>>.from(widget.authorsList);
    _authors = List<Map<String, dynamic>>.from(widget.authorsList);
    _searchController.addListener(_filterAuthors);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterAuthors() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _authors = _allAuthors
          .where((author) =>
      author['name'] != null &&
          author['name'].toString().toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    final success = await MediaPickerHelper.pickImage((file) {
      setState(() => _pickedImage = file);
    });

    if (!mounted) return;

    if (!success) {
      showSnackBar(context, 'Please allow image access to select a photo.', type: SnackBarType.error);
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate() && _pickedImage != null) {
      setState(() => _isLoading = true);
      try {
        await _authorService.createAuthor(
          authorProfile: _pickedImage!,
          authorName: _nameController.text.trim(),
        );

        final updatedAuthorsList = await _authorService.getAuthors();

        if (!mounted) return;
        showSnackBar(context, 'Author created successfully', type: SnackBarType.success);

        Navigator.pop(context, updatedAuthorsList);
      } catch (e) {
        if (!mounted) return;
        showSnackBar(context, 'Failed to create author: $e', type: SnackBarType.error);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      showSnackBar(context, 'Please fill in all required fields and select an image', type: SnackBarType.error);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Authors')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  buildImagePicker(
                    filePath: _pickedImage,
                    onPressed: _pickImage,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Author Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter author name' : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Add Author'),
                    ),
                  ),
                ],
              ),
            ),
            if (_isLoading)
              const LinearProgressIndicator(
                minHeight: 4,
                backgroundColor: Colors.transparent,
              ),
          ],
        ),
      ),
    );
  }
}
