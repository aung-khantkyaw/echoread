import 'package:flutter/material.dart';

import 'package:echoread/core/utils/validators.dart';

import 'package:echoread/core/widgets/input_decoration.dart';

import '../../services/auth_service.dart';

class RegistrationForm extends StatefulWidget {
  const RegistrationForm({super.key});

  @override
  State<RegistrationForm> createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _invalidCredential = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? error;

  Future<void> _registration() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _invalidCredential = false;
        _isLoading = true;
      });

      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final errorCode = await _authService.registration(username, email, password);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      if (errorCode != null) {
        setState(() {
          _invalidCredential = true;
        });
        error = Validators.validateRegistrationErrorReturn(errorCode);
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
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
            controller: _usernameController,
            decoration: commonInputDecoration('Username'),
            validator: Validators.validateUsername,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _emailController,
            decoration: commonInputDecoration('Email'),
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _passwordController,
            decoration: commonInputDecoration(
              'Password',
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
            validator: (value) => Validators.validateRegistrationPassword(value),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: commonInputDecoration(
              'Confirm Password',
            ).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            obscureText: _obscureConfirmPassword,
            validator: (value) => Validators.validateConfirmPassword(
              value,
              _passwordController.text,
            ),
          ),
          const SizedBox(height: 20),
          if (_invalidCredential)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                error ?? 'Account create is not success.',
                style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registration,
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
                  : const Text('Registration'),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Already have an account? "),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text(
                  'Login',
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
