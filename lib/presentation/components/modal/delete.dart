import 'package:flutter/material.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onDelete;
  final VoidCallback onCancel;

  const ConfirmDeleteDialog({
    super.key,
    required this.title,
    required this.content,
    required this.onDelete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: onDelete,
          child: const Text('Delete'),
        ),
      ],
    );
  }
}
