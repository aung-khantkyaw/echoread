import 'package:flutter/material.dart';

import '../widgets/registration_form.dart';

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});
  static const String routeName = '/registration';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF4ED),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RegistrationForm(),
      ),
    );
  }
}
