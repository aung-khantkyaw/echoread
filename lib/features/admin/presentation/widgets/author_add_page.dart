import 'dart:io';
import 'package:flutter/material.dart';

import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/build_image_picker.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:echoread/core/utils/media_picker_helper.dart';
import 'package:echoread/features/admin/services/author_manage_service.dart';

import 'package:echoread/l10n/app_localizations.dart';

class AuthorAddPage extends StatefulWidget {
  final List<Map<String, dynamic>> authorsList;

  const AuthorAddPage({super.key, required this.authorsList});

  @override
  State<AuthorAddPage> createState() => _AuthorAddPageState();
}

class _AuthorAddPageState extends State<AuthorAddPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  File? _pickedImage;

  final _authorService = AuthorManageService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
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
    final locale = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: commonAppBar(
        context: context,
        title: locale.add_author
      ),
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
                    placeholderText: locale.select_image_hint,
                    height: 320
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: locale.author_name,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty ? 'Please enter author name' : null,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
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
                        : Text(locale.add_author),  
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
