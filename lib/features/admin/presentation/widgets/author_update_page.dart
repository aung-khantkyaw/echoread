import 'dart:io';

import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:echoread/core/config/cloudinary_config.dart';
import 'package:echoread/core/widgets/build_image_picker.dart';
import '../../services/author_manage_service.dart';

class AuthorUpdatePage extends StatefulWidget {
  final String authorId;
  final String? profileImg;
  final String authorName;

  const AuthorUpdatePage({
    super.key,
    required this.authorId,
    required this.authorName,
    this.profileImg,
  });

  @override
  State<AuthorUpdatePage> createState() => _AuthorUpdatePageState();
}

class _AuthorUpdatePageState extends State<AuthorUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _pickedImage;

  final _authorService = AuthorManageService();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.authorName);
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedName = _nameController.text.trim();

    try {
      await _authorService.updateAuthorWithImageSupport(
        authorId: widget.authorId,
        authorName: updatedName,
        profileImageFile: _pickedImage,
        existingImageUrl: widget.profileImg,
      );

      final updatedAuthorsList = await _authorService.getAuthors();

      if (!mounted) return;
      showSnackBar(context, "Author updated successfully", type: SnackBarType.success);

      Navigator.pop(context, updatedAuthorsList);
    } catch (e) {
      showSnackBar(context, "Failed to update author: $e",  type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkImageUrl = widget.profileImg != null && widget.profileImg!.isNotEmpty
        ? CloudinaryConfig.baseUrl(widget.profileImg!, MediaType.image)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Author'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildImagePicker(
                filePath: _pickedImage,
                networkImageUrl: networkImageUrl,
                onPressed: _pickImage,
              ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Author Name'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter author name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
