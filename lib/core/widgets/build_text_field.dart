import 'package:flutter/material.dart';

Widget buildTextField({
  required String label,
  required TextEditingController controller,
  required String? Function(String?) validator,
  int maxLines = 1,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      validator: validator,
      maxLines: maxLines,
    ),
  );
}