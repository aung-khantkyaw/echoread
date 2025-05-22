import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echoread/core/utils/validators.dart';

import 'package:echoread/core/widgets/input_decoration.dart';

import '../../services/auth_service.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _invalidCredential = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _invalidCredential = false;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final result = await _authService.login(email, password);
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (result != null) {
          Navigator.pushReplacementNamed(context, '/home');
      } else {
        setState(() => _invalidCredential = true);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _invalidCredential = true;
      });
      debugPrint('Login failed: ${e.code}');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _invalidCredential = true;
      });
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
              fontFamily: 'CinzelBold',
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 24),

          TextFormField(
            controller: _emailController,
            decoration: commonInputDecoration('Email', isError: _invalidCredential),
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: commonInputDecoration(
              'Password',
              isError: _invalidCredential,
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/forget-password');
              },
              child: Text(
                'Forget Password?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (_invalidCredential)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Email or password is incorrect',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4B1E0A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'AncizarSerifBold',
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 40,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text('Login'),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/registration');
                },
                child: Text(
                  'Registration',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
