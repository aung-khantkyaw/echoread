import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'package:echoread/core/widgets/app_bar.dart';
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
  final List<String?> _audioFilePaths = [null];

  List<Map<String, dynamic>> _filteredAuthors = [];

  final BookManageService _bookService = BookManageService();
  final List<bool> _isUploadingAudioList = [false];
  final bool _hasFileSizeError = false;
  bool _isLoading = false;
  bool _isUploadingEbook = false;

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
    setState(() => _isUploadingEbook = true);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'epub'],
      );

      if (!mounted) return;

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        setState(() {
          _ebookFilePath = path;
          _isUploadingEbook = false;
        });
      } else {
        setState(() => _isUploadingEbook = false);
        showSnackBar(context, 'No ebook file selected.', type: SnackBarType.error);
      }
    } catch (e) {
      setState(() => _isUploadingEbook = false);
      showSnackBar(context, 'Something went wrong picking the ebook file.', type: SnackBarType.error);
      log('Ebook file pick error: $e');
    }
  }

  Future<void> _pickAudioFile(int index) async {
    setState(() => _isUploadingAudioList[index] = true);

    final path = await MediaPickerHelper.pickAudio();

    if (!mounted) return;

    if (path != null) {
      setState(() {
        _audioFilePaths[index] = path;
        _isUploadingAudioList[index] = false;
      });
    } else {
      setState(() => _isUploadingAudioList[index] = false);
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

        log('Calling createBook...');
        await _bookService.createBook(
          bookImage: _pickedImage!,
          ebookFile: File(_ebookFilePath!),
          audioFiles: audioFiles,
          bookName: _nameController.text,
          bookDescription: _descController.text,
          authorId: _selectedAuthorId!,
        );

        final updatedBookList = await _bookService.getBooks();

        if (!mounted) return;
        showSnackBar(context, 'Book created successfully', type: SnackBarType.success);
        Navigator.pop(context, updatedBookList);
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
      appBar: commonAppBar(
        context: context,
        title: locale.add_book
      ),
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

                  const SizedBox(height: 8),

                  buildFilePicker(
                    label: locale.ebook_file,
                    filePath: _ebookFilePath,
                    onPressed: _pickEbookFile,
                    placeholder: locale.no_file_selected,
                    isUploading: _isUploadingEbook,
                  ),

                  const SizedBox(height: 8),

                  Column(
                    children: [
                      ...List.generate(_audioFilePaths.length, (index) {
                        return Column(
                          children: [
                            buildFilePicker(
                              label: '${locale.audio_file} ${index + 1}',
                              filePath: _audioFilePaths[index],
                              onPressed: () => _pickAudioFile(index),
                              placeholder: locale.no_file_selected,
                              isUploading: _isUploadingAudioList[index],
                            ),
                            const SizedBox(height: 12), // padding between file pickers
                          ],
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _audioFilePaths.add(null);
                              _isUploadingAudioList.add(false);
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: Text(locale.add_another_audio_file),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  buildTextField(
                    label: locale.book_description,
                    controller: _descController,
                    validator: (v) => v == null || v.isEmpty ? 'Enter description' : null,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    // onPressed: _isLoading ? null : _submitForm,
                    onPressed: (_isLoading || _hasFileSizeError) ? null : _submitForm,
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
                    child: _isLoading ? Text(locale.adding) : Text(locale.save_book),
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
