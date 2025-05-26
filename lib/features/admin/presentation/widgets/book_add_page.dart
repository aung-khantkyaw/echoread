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

import 'package:echoread/l10n/app_localizations.dart';

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
  List<String?> _audioFilePaths = [null];

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

  Future<void> _pickAudioFile(int index) async {
    final success = await MediaPickerHelper.pickAudio((path) {
      setState(() => _audioFilePaths[index] = path);
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
    final isValid = _formKey.currentState!.validate();
    final hasAudio = _audioFilePaths.any((path) => path != null && path.isNotEmpty);

    if (isValid && _selectedAuthorId != null && _pickedImage != null && _ebookFilePath != null && hasAudio) {
      setState(() => _isLoading = true);
      try {
        final audioFiles = _audioFilePaths
            .where((path) => path != null && path.isNotEmpty)
            .map((path) => File(path!))
            .toList();

        await _bookService.createBook(
          bookImage: _pickedImage!,
          ebookFile: File(_ebookFilePath!),
          audioFiles: audioFiles,
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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(locale.add_book)),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildImagePicker(filePath: _pickedImage, onPressed: _pickImage, placeholderText: locale.select_image_hint),
                  buildTextField(
                    label: locale.book_name,
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? 'Enter book name' : null,
                  ),
                  buildSearchableDropdown(
                    context: context,
                    label: locale.select_author,
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
                    label: locale.ebook_file,
                    filePath: _ebookFilePath,
                    onPressed: _pickEbookFile,
                    placeholder: locale.no_file_selected
                  ),
                  Column(
                    children: [
                      ...List.generate(_audioFilePaths.length, (index) {
                        return buildFilePicker(
                          label: '${locale.audio_file} ${index + 1}',
                          filePath: _audioFilePaths[index],
                          onPressed: () => _pickAudioFile(index),
                          placeholder: locale.no_file_selected
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() => _audioFilePaths.add(null));
                          },
                          icon: const Icon(Icons.add),
                          label: Text(locale.add_another_audio_file),
                        ),
                      ),
                    ],
                  ),
                  buildTextField(
                    label: locale.book_description,
                    controller: _descController,
                    validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: Text(locale.save_book),
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
