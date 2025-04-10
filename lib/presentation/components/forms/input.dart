import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class FormInputEmail extends StatelessWidget {
  final TextEditingController controller;
  final bool isPrimary;
  final String label;
  final bool isRequired;

  const FormInputEmail(
      {super.key,
      required this.controller,
      required this.isPrimary,
      this.label = '',
      this.isRequired = false});

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
              color: isPrimary ? white : lightGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isPrimary ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]),
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
            validator: emailValidator,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
}

class FormInputPassword extends StatelessWidget {
  final TextEditingController controller;
  final bool isPrimary;
  final String label;
  final bool isRequired;

  const FormInputPassword(
      {super.key,
      required this.controller,
      required this.isPrimary,
      this.label = '',
      this.isRequired = false});

  // validator
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (isRequired)
                    TextSpan(
                      text: " *",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
              color: isPrimary ? white : lightGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isPrimary ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]),
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
            validator: passwordValidator,
            keyboardType: TextInputType.emailAddress,
          ),
        ),
      ],
    );
  }
}
