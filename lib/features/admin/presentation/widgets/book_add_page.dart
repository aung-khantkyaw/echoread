import 'dart:io';
import 'package:echoread/core/widgets/build_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import 'package:echoread/core/widgets/build_file_picker.dart';
import 'package:echoread/core/widgets/build_text_field.dart';

import 'package:echoread/core/config/upload_image.dart';

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
  String? _pickedImageUrl;
  String? _ebookFilePath;
  String? _audioFilePath;

  List<Map<String, dynamic>> _filteredAuthors = [];

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

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    // if (picked != null) setState(() => _pickedImage = File(picked.path));
    if (picked != null) {
      final file = File(picked.path);
      final url = await uploadImageToCloudinary(file);
      if (url != null) {
        setState(() {
          _pickedImage = file;
          _pickedImageUrl = url;
        });
        print('Image uploaded! URL: $url');
      }
    }
  }

  Future<void> _pickEbookFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'epub'],
    );
    if (result?.files.single.path != null) {
      setState(() => _ebookFilePath = result!.files.single.path!);
    }
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result?.files.single.path != null) {
      setState(() => _audioFilePath = result!.files.single.path!);
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedAuthorId != null) {
      final bookData = {
        'book_name': _nameController.text,
        'book_description': _descController.text,
        'ebook_url': _ebookFilePath,
        'audio_url': _audioFilePath,
        'author_id': _selectedAuthorId,
        'book_img': _pickedImageUrl,
      };
      print('Book Data: $bookData');
      // Navigator.pop(context, bookData);
    } else if (_selectedAuthorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an author')),
      );
    }
  }

  Widget _buildAuthorSearchField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTextField(
          label: 'Search Author',
          controller: _authorSearchController,
          validator: (_) => _selectedAuthorId == null ? 'Select an author' : null,
        ),
        if (_authorSearchController.text.isNotEmpty && _filteredAuthors.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
            ),
            child: ListView.builder(
              itemCount: _filteredAuthors.length,
              itemBuilder: (_, index) {
                final author = _filteredAuthors[index];
                return ListTile(
                  title: Text(author['name']),
                  onTap: () {
                    setState(() {
                      _selectedAuthorId = author['id'].toString();
                      _authorSearchController.text = author['name'];
                      _filteredAuthors = [];
                      FocusScope.of(context).unfocus();
                    });
                  },
                );
              },
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Book')),
      body: SingleChildScrollView(
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
              _buildAuthorSearchField(),
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
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Book'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
