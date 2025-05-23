import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class PrimaryButton extends StatelessWidget {
  final dynamic label;
  final VoidCallback onPressed;
  final Color? color;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: white,
        foregroundColor: black,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0));

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: label is CircularProgressIndicator ? label : Text(label),
    );
  }
}

class AccentButton extends StatelessWidget {
  final dynamic label;
  final VoidCallback onPressed;

  const AccentButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: accentPurple,
        foregroundColor: white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0));

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: label is CircularProgressIndicator ? label : Text(label),
    );
  }
}
