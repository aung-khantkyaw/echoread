import 'package:flutter/material.dart';

import 'package:echoread/core/utils/validators.dart';
import 'package:echoread/core/widgets/common_input_decoration.dart';

import '../../services/auth_service.dart';

class ForgetPasswordForm extends StatefulWidget {
  const ForgetPasswordForm({super.key});

  @override
  State<ForgetPasswordForm> createState() => _ForgetPasswordFormState();
}

class _ForgetPasswordFormState extends State<ForgetPasswordForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _forget() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();

    try {
      final result = await _authService.forgetPassword(email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show result as a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Something went wrong.'),
          backgroundColor: result?.startsWith('Password') == true
              ? Colors.green
              : Colors.red,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred.'),
          backgroundColor: Colors.red,
        ),
      );

      debugPrint('Unexpected error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'EchoRead',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cinzel',
              color: Colors.black87,
            ),
          ),
          Text(
            'Enter e-mail to receive reset link',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),

          TextFormField(
            controller: _emailController,
            decoration: commonInputDecoration('Email'),
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, // takes full available width
            child: ElevatedButton(
              onPressed: _isLoading ? null : _forget,
              child: _isLoading
                  ? const SizedBox(
                width: 40,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Send Link'),
            ),
          ),
        ],
      ),
    );
  }
}
