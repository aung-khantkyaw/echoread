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
import 'package:echoread/core/config/cloudinary_config.dart';

import 'package:echoread/features/admin/services/book_manage_service.dart';
import 'package:echoread/l10n/app_localizations.dart';

class BookUpdatePage extends StatefulWidget {
  final Map<String, dynamic> bookData;
  final List<Map<String, dynamic>> authorsList;

  const BookUpdatePage({
    super.key,
    required this.bookData,
    required this.authorsList,
  });

  @override
  State<BookUpdatePage> createState() => _BookUpdatePageState();
}

class _BookUpdatePageState extends State<BookUpdatePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _authorSearchController;

  String? _selectedAuthorId;

  String? _existingBookImgUrl;
  String? _existingEbookUrl;
  List<String> _existingAudioUrls = [];

  File? _newPickedImage;
  File? _newPickedEbookFile;
  final List<dynamic> _currentAudioItems = [];

  List<Map<String, dynamic>> _filteredAuthors = [];

  final BookManageService _bookService = BookManageService();
  final List<bool> _isUploadingAudioList = [];
  bool _isLoading = false;
  bool _isUploadingEbook = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.bookData['book_name'] as String? ?? '');
    _descController = TextEditingController(text: widget.bookData['book_description'] as String? ?? '');

    _selectedAuthorId = (widget.bookData['author_id'] as String?);
    final currentAuthor = widget.authorsList.firstWhere(
          (author) => author['id'] == _selectedAuthorId,
      orElse: () => {'name': ''},
    );
    _authorSearchController = TextEditingController(text: currentAuthor['name'] as String? ?? '');

    _filteredAuthors = widget.authorsList;
    _authorSearchController.addListener(_filterAuthors);

    _existingBookImgUrl = widget.bookData['book_img'] as String?;
    _existingEbookUrl = (widget.bookData['ebook_urls'] as List<dynamic>?)?.firstOrNull as String?;
    _existingAudioUrls = List<String>.from(widget.bookData['audio_urls'] as List<dynamic>? ?? []);

    for (var url in _existingAudioUrls) {
      _currentAudioItems.add(url);
      _isUploadingAudioList.add(false);
    }
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
          .where((author) => (author['name'] as String).toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _pickImage() async {
    setState(() => _isUploadingImage = true);
    final success = await MediaPickerHelper.pickImage((file) {
      setState(() {
        _newPickedImage = file;
        _isUploadingImage = false;
      });
    });

    if (!mounted) return;

    if (!success) {
      setState(() => _isUploadingImage = false);
      showSnackBar(context, AppLocalizations.of(context)!.image_access_denied, type: SnackBarType.error);
    }
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
          _newPickedEbookFile = File(path);
          _isUploadingEbook = false;
        });
      } else {
        setState(() => _isUploadingEbook = false);
        showSnackBar(context, AppLocalizations.of(context)!.no_ebook_file_selected, type: SnackBarType.error);
      }
    } catch (e) {
      setState(() => _isUploadingEbook = false);
      showSnackBar(context, AppLocalizations.of(context)!.ebook_file_pick_error, type: SnackBarType.error);
      log('Ebook file pick error: $e');
    }
  }

  Future<void> _pickAudioFile(int index) async {
    setState(() => _isUploadingAudioList[index] = true);

    final path = await MediaPickerHelper.pickAudio();

    if (!mounted) return;

    if (path != null) {
      setState(() {
        _currentAudioItems[index] = File(path);
        _isUploadingAudioList[index] = false;
      });
    } else {
      setState(() => _isUploadingAudioList[index] = false);
      showSnackBar(context, AppLocalizations.of(context)!.audio_access_denied, type: SnackBarType.error);
    }
  }

  void _addAudioFileInput() {
    setState(() {
      _currentAudioItems.add(null);
      _isUploadingAudioList.add(false);
    });
  }

  void _removeAudioFileInput(int index) {
    setState(() {
      _currentAudioItems.removeAt(index);
      _isUploadingAudioList.removeAt(index);
    });
  }


  Future<void> _submitForm() async {
    final locale = AppLocalizations.of(context)!;
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      showSnackBar(context, locale.validation_error, type: SnackBarType.error);
      return;
    }

    final hasAudioItems = _currentAudioItems.any((item) => item != null);
    if (_newPickedImage == null && _existingBookImgUrl == null) {
      showSnackBar(context, locale.select_book_cover_hint, type: SnackBarType.error);
      return;
    }
    if (_newPickedEbookFile == null && _existingEbookUrl == null) {
      showSnackBar(context, locale.select_ebook_file_hint, type: SnackBarType.error);
      return;
    }
    if (!hasAudioItems) {
      showSnackBar(context, locale.select_audio_file_hint, type: SnackBarType.error);
      return;
    }
    if (_selectedAuthorId == null) {
      showSnackBar(context, locale.select_author_hint, type: SnackBarType.error);
      return;
    }


    setState(() => _isLoading = true);

    try {
      final List<File> audioFilesToUpload = [];
      final List<String> audioUrlsToKeep = [];

      for (var item in _currentAudioItems) {
        if (item is File) {
          audioFilesToUpload.add(item);
        } else if (item is String) {
          audioUrlsToKeep.add(item);
        }
      }

      await _bookService.updateBook(
        bookId: widget.bookData['id'],
        bookName: _nameController.text,
        bookDescription: _descController.text,
        authorId: _selectedAuthorId!,
        newBookImage: _newPickedImage,
        existingBookImageUrl: _existingBookImgUrl,
        newEbookFile: _newPickedEbookFile,
        existingEbookUrl: _existingEbookUrl,
        newAudioFiles: audioFilesToUpload,
        existingAudioUrlsToKeep: audioUrlsToKeep,
        originalAudioUrls: _existingAudioUrls,
        originalEbookUrl: _existingEbookUrl,
        originalBookImgUrl: _existingBookImgUrl,
      );

      if (!mounted) return;
      showSnackBar(context, locale.book_updated_successfully, type: SnackBarType.success);
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showSnackBar(context, '${locale.failed_to_update_book}: $e', type: SnackBarType.error);
      log('Book update error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;

    String? currentBookImgDisplayPath;
    if (_newPickedImage != null) {
      currentBookImgDisplayPath = _newPickedImage!.path;
    } else if (_existingBookImgUrl != null) {
      currentBookImgDisplayPath = CloudinaryConfig.baseUrl(_existingBookImgUrl!, MediaType.image);
    }

    // Determine the current ebook path for display
    String? currentEbookDisplayPath;
    if (_newPickedEbookFile != null) {
      currentEbookDisplayPath = _newPickedEbookFile!.path;
    } else if (_existingEbookUrl != null) {
      currentEbookDisplayPath = _existingEbookUrl;
    }

    return Scaffold(
      appBar: commonAppBar(
        context: context,
        title: locale.update_book,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  buildImagePicker(
                    filePath: _newPickedImage,
                    networkImageUrl: _existingBookImgUrl != null
                        ? CloudinaryConfig.baseUrl(_existingBookImgUrl!, MediaType.image)
                        : null,
                    onPressed: _pickImage,
                    placeholderText: locale.select_image_hint,
                    height: 320,
                    isUploading: _isUploadingImage,
                  ),
                  buildTextField(
                    label: locale.book_name,
                    controller: _nameController,
                    validator: (v) => v == null || v.isEmpty ? locale.enter_book_name : null,
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
                      return _selectedAuthorId == null ? locale.select_an_author : null;
                    },
                  ),

                  const SizedBox(height: 8),

                  buildFilePicker(
                    label: locale.ebook_file,
                    filePath: _newPickedEbookFile?.path,
                    networkUrl: _existingEbookUrl,
                    onPressed: _pickEbookFile,
                    placeholder: locale.no_file_selected,
                    isUploading: _isUploadingEbook,
                  ),

                  const SizedBox(height: 8),

                  Column(
                    children: [
                      ...List.generate(_currentAudioItems.length, (index) {
                        final audioItem = _currentAudioItems[index];
                        String? filePath;
                        String? networkUrl;

                        if (audioItem is File) {
                          filePath = audioItem.path;
                        } else if (audioItem is String) {
                          networkUrl = CloudinaryConfig.baseUrl(audioItem, MediaType.audio);
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: buildFilePicker(
                                  label: '${locale.audio_file} ${index + 1}',
                                  filePath: filePath,
                                  networkUrl: networkUrl,
                                  onPressed: () => _pickAudioFile(index),
                                  placeholder: locale.no_file_selected,
                                  isUploading: _isUploadingAudioList.length > index ? _isUploadingAudioList[index] : false, // Safety check
                                ),
                              ),
                              if (_currentAudioItems.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                                  onPressed: () => _removeAudioFileInput(index),
                                ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: _addAudioFileInput,
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
                    validator: (v) => v == null || v.isEmpty ? locale.enter_book_description : null,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
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
                    child: _isLoading ? Text(locale.updating) : Text(locale.save_changes),
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