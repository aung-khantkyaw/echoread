import 'package:flutter/material.dart';

InputDecoration commonInputDecoration(String label, {bool isError = false}) {
  return InputDecoration(
    labelText: label,
    errorText: isError ? '' : null,
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
    border: OutlineInputBorder(),
  );
}
