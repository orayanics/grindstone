import 'package:flutter/material.dart';

class FormInputEmail extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const FormInputEmail({
    super.key,
    required this.controller,
    this.validator,
  });

  // validator
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // remove form field border and underline
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: 'johndoe@email.com',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        controller: controller,
        validator: validator ?? emailValidator,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}

class FormInputPassword extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const FormInputPassword({
    super.key,
    required this.controller,
    this.validator,
  });

  // validator
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: '********',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        controller: controller,
        validator: validator ?? passwordValidator,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }
}
