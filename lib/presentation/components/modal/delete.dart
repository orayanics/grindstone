import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/exports/components.dart';

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
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      title: Text('Confirm Delete',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: accentRed,
              )),
      content: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(content,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textLight,
                    )),
            const SizedBox(height: 16),
            Text('This action cannot be undone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textLight,
                    )),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: AccentButton(
            onPressed: onDelete,
            label: 'Delete',
          ),
        ),
      ],
    );
  }
}
