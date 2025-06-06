import 'dart:io';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:echoread/core/config/cloudinary_config.dart';
import 'package:echoread/core/widgets/build_image_picker.dart';
import '../../services/author_manage_service.dart';

import 'package:echoread/l10n/app_localizations.dart';

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
  bool _isLoading = false;

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

    setState(() => _isLoading = true);

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
      showSnackBar(context, "Failed to update author: $e", type: SnackBarType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    
    final networkImageUrl = widget.profileImg != null && widget.profileImg!.isNotEmpty
        ? CloudinaryConfig.baseUrl(widget.profileImg!, MediaType.image)
        : null;

    return Scaffold(
      appBar: commonAppBar(
        context: context,
        title: locale.update_author
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  buildImagePicker(
                    filePath: _pickedImage,
                    networkImageUrl: networkImageUrl,
                    onPressed: _pickImage,
                    placeholderText: locale.select_image_hint,
                    height: 320
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: locale.author_name,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter author name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
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
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(locale.update_author),
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
