import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class FormInputEmail extends StatefulWidget {
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

  @override
  State<FormInputEmail> createState() => _FormInputEmailState();
}

class _FormInputEmailState extends State<FormInputEmail> {
  String? errorMessage;

  // validator returns true if valid, false if invalid
  bool emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your email';
      });
      return false;
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      setState(() {
        errorMessage = 'Please enter a valid email address';
      });
      return false;
    }
    setState(() {
      errorMessage = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isRequired)
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
            color: widget.isPrimary ? white : lightGray,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: widget.isPrimary ? Colors.transparent : Colors.black12,
                blurRadius: 4,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'johndoe@email.com',
                    border: InputBorder.none,
                    errorStyle: const TextStyle(
                      color: accentRed,
                      fontSize: 0,
                    ),
                  ),
                  controller: widget.controller,
                  validator: (value) => emailValidator(value) ? null : '',
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
            ],
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: accentRed,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}

class FormInputPassword extends StatefulWidget {
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

  @override
  State<FormInputPassword> createState() => _FormInputPasswordState();
}

class _FormInputPasswordState extends State<FormInputPassword> {
  bool _hidePassword = true;
  String? errorMessage;

  // validator returns true if valid, false if invalid
  bool passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your password';
      });
      return false;
    }
    setState(() {
      errorMessage = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isRequired)
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
              color: widget.isPrimary ? white : lightGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: '********',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                errorStyle: const TextStyle(
                  color: accentRed,
                  fontSize: 0,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _hidePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _hidePassword = !_hidePassword;
                    });
                  },
                ),
              ),
              controller: widget.controller,
              validator: (value) => passwordValidator(value) ? null : '',
              obscureText: _hidePassword,
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: accentRed,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}

class FormInputText extends StatefulWidget {
  final TextEditingController controller;
  final bool isPrimary;
  final String label;
  final bool isRequired;

  const FormInputText(
      {super.key,
      required this.controller,
      required this.isPrimary,
      this.label = '',
      this.isRequired = false});

  @override
  State<FormInputText> createState() => _FormInputTextState();
}

class _FormInputTextState extends State<FormInputText> {
  String? errorMessage;

  // validator returns true if valid, false if invalid
  bool textValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your text';
      });
      return false;
    }
    final textRegex = RegExp(r'^[a-zA-Z]+$');
    if (!textRegex.hasMatch(value)) {
      setState(() {
        errorMessage = 'Please enter only letters';
      });
      return false;
    }
    setState(() {
      errorMessage = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isRequired)
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
              color: widget.isPrimary ? white : lightGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'John Doe',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                errorStyle: const TextStyle(
                  color: accentRed,
                  fontSize: 0,
                ),
              ),
              controller: widget.controller,
              validator: (value) => textValidator(value) ? null : '',
              keyboardType: TextInputType.text,
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: accentRed,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}

class FormInputNumber extends StatefulWidget {
  final TextEditingController controller;
  final bool isPrimary;
  final String label;
  final bool isRequired;

  const FormInputNumber(
      {super.key,
      required this.controller,
      required this.isPrimary,
      this.label = '',
      this.isRequired = false});

  @override
  State<FormInputNumber> createState() => _FormInputNumberState();
}

class _FormInputNumberState extends State<FormInputNumber> {
  String? errorMessage;

  // validator returns true if valid, false if invalid
  bool numberValidator(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your number';
      });
      return false;
    }
    final numberRegex = RegExp(r'^[0-9]+$');
    if (!numberRegex.hasMatch(value)) {
      setState(() {
        errorMessage = 'Please enter only numbers';
      });
      return false;
    }
    setState(() {
      errorMessage = null;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: widget.label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (widget.isRequired)
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
              color: widget.isPrimary ? white : lightGray,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.isPrimary ? Colors.transparent : Colors.black12,
                  blurRadius: 4,
                  offset: const Offset(0, 0),
                ),
              ]),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: '0.0',
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                errorStyle: const TextStyle(
                  color: accentRed,
                  fontSize: 0,
                ),
              ),
              controller: widget.controller,
              validator: (value) => numberValidator(value) ? null : '',
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: accentRed,
                fontSize: 12.0,
              ),
            ),
          ),
      ],
    );
  }
}
