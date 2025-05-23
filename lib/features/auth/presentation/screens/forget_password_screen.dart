import 'package:flutter/material.dart';

import '../widgets/forget_password_form.dart';

class ForgetPasswordPage extends StatelessWidget {
  const ForgetPasswordPage({super.key});
  static const String routeName = '/forget-password';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ForgetPasswordForm(),
      ),
    );
  }
}
