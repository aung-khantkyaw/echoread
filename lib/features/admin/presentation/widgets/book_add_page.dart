import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:echoread/core/widgets/build_image_picker.dart';
import 'package:echoread/core/widgets/build_file_picker.dart';
import 'package:echoread/core/widgets/build_text_field.dart';
import 'package:echoread/core/widgets/build_searchable_dropdown.dart';
import 'package:echoread/core/utils/media_picker_helper.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';

import 'package:echoread/features/admin/services/book_manage_service.dart';

class BookAddForm extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const BookAddForm({super.key, required this.authorsList});
  static const String routeName = '/book-add';

  @override
  State<BookAddForm> createState() => _BookAddFormState();
}

class _BookAddFormState extends State<BookAddForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _authorSearchController = TextEditingController();

  String? _selectedAuthorId;
  File? _pickedImage;
  String? _ebookFilePath;
  String? _audioFilePath;

  List<Map<String, dynamic>> _filteredAuthors = [];

  final _bookService = BookManageService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _filteredAuthors = widget.authorsList;
    _authorSearchController.addListener(_filterAuthors);
  }

  @override
  void dispose() {
    _authorSearchController.removeListener(_filterAuthors);
    _authorSearchController.dispose();
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _filterAuthors() {
    final query = _authorSearchController.text.toLowerCase();
    setState(() {
      _filteredAuthors = widget.authorsList
          .where((author) => author['name'].toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _pickEbookFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );

    if (!mounted) return;

    if (result != null && result.files.single.path != null) {
      setState(() => _ebookFilePath = result.files.single.path!);
    } else {
      showSnackBar(context, 'No ebook file selected.', type: SnackBarType.error);
    }
  }

  Future<void> _pickAudioFile() async {
    final success = await MediaPickerHelper.pickAudio((path) {
      setState(() => _audioFilePath = path);
    });

    if (!mounted) return;

    if (!success) {
      showSnackBar(context, 'Please allow audio access to select a file.', type: SnackBarType.error);
    }
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
    if (_formKey.currentState!.validate() &&
        _selectedAuthorId != null &&
        _pickedImage != null &&
        _ebookFilePath != null &&
        _audioFilePath != null) {
      setState(() => _isLoading = true);
      try {
        await _bookService.createBook(
          bookImage: _pickedImage!,
          ebookFile: File(_ebookFilePath!),
          audioFile: File(_audioFilePath!),
          bookName: _nameController.text,
          bookDescription: _descController.text,
          authorId: _selectedAuthorId!,
        );

        if (!mounted) return;
        showSnackBar(context, 'Book created successfully', type: SnackBarType.success);

        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        showSnackBar(context, 'Failed to create book: $e', type: SnackBarType.error);
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      showSnackBar(context, 'Please fill in all required fields', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildImagePicker(filePath: _pickedImage, onPressed: _pickImage),
                  buildTextField(
                    label: 'Book Name',
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'Enter book name' : null,
                  ),
                  buildSearchableDropdown(
                    context: context,
                    label: 'Search Author',
                    controller: _authorSearchController,
                    filteredItems: _filteredAuthors,
                    selectedId: _selectedAuthorId,
                    onSelect: (author) {
                      setState(() {
                        _selectedAuthorId = author['id'].toString();
                        _authorSearchController.text = author['name'];
                        _filteredAuthors = [];
                      });
                    },
                    validator: (value) {
                      return _selectedAuthorId == null ? 'Select an author' : null;
                    },
                  ),
                  buildFilePicker(
                    label: 'Ebook File',
                    filePath: _ebookFilePath,
                    onPressed: _pickEbookFile,
                  ),
                  buildFilePicker(
                    label: 'Audio File',
                    filePath: _audioFilePath,
                    onPressed: _pickAudioFile,
                  ),
                  buildTextField(
                    label: 'Book Description',
                    controller: _descController,
                    validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Save Book'),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              minHeight: 4,
              backgroundColor: Colors.transparent,
            ),
        ],
      ),
    );
  }
}
