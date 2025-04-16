import 'package:flutter/material.dart';

class ExerciseListItem extends StatelessWidget {
  final Map<String, String> exercise;
  final VoidCallback onDelete;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(exercise['name'] ?? 'Unnamed Exercise'),
        leading: IconButton(
          icon: Icon(Icons.delete),
          onPressed: onDelete,
        ),
      ),
    );
  }
}
