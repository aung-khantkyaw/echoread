import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({Key? key}) : super(key: key);
  static const String routeName = '/change-email';
  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _updateEmail() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user logged in')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final newEmail = _newEmailController.text.trim();
    final password = _passwordController.text;

    try {
      // Re-authenticate
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);

      // Send verification email (optional but recommended)
      await user.sendEmailVerification();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email updated successfully! Please verify your new email.')),
      );

      // Clear fields
      _newEmailController.clear();
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Failed to update email.';
      if (e.code == 'wrong-password') {
        message = 'The password is incorrect.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The new email is already in use by another account.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Please log out and log back in again and try.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Email Address'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _newEmailController,
                decoration: const InputDecoration(
                  labelText: 'New Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new email';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Enter a valid email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your password' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateEmail,
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text('Update Email'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
