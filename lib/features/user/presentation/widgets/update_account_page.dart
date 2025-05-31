import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:echoread/core/widgets/app_bar.dart';
import 'package:echoread/core/widgets/show_snack_bar.dart';
import 'package:echoread/core/widgets/build_image_picker.dart';
import 'package:echoread/core/config/cloudinary_config.dart';
import 'package:echoread/l10n/app_localizations.dart';

import '../../services/account_manage_service.dart';

class AccountUpdatePage extends StatefulWidget {
  final String accountId;
  final String? profileImg;
  final String username;

  const AccountUpdatePage({
    super.key,
    required this.accountId,
    required this.username,
    this.profileImg,
  });
  static const String routeName = '/update-account';

  @override
  State<AccountUpdatePage> createState() => _AccountUpdatePageState();
}

class _AccountUpdatePageState extends State<AccountUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  File? _pickedImage;
  bool _isLoading = false;

  final _accountService = AccountManageService(); // သင့် service class name

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.username);
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
      await _accountService.updateAccountWithImageSupport(
        accountId: widget.accountId,
        username: updatedName,
        profileImageFile: _pickedImage,
        existingImageUrl: widget.profileImg,
      );

      if (!mounted) return;

      showSnackBar(context, "Account updated successfully", type: SnackBarType.success);
      Navigator.pop(context, true); // or pass updated user data if needed
    } catch (e) {
      showSnackBar(context, "Failed to update account: $e", type: SnackBarType.error);
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
        title: locale.update_account,
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
                    height: 320,
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: locale.username,
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return locale.username_required;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066CC),
                      foregroundColor: Colors.white,
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
                        : Text(locale.update_account),
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
