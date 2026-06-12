import 'package:flutter/material.dart';

class AppTextField
    extends StatelessWidget {

  final TextEditingController
      controller;

  final String hint;

  final TextInputType?
      keyboardType;

  final int maxLines;

  final String? Function(String?)?
      validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType:
          keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration:
          InputDecoration(
        hintText: hint,
      ),
    );
  }
}