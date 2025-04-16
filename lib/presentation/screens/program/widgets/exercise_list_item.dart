import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

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
        elevation: 0,
        color: white,
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.all(Radius.circular(12)),
              boxShadow: [
                BoxShadow(
                    color: const Color.fromARGB(12, 0, 0, 0),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(1, 0))
              ]),
          child: ListTile(
            title: Text(exercise['name'] ?? 'Unnamed Exercise'),
            subtitle: Text(exercise['sets'] ?? '0 sets'),
            leading: IconButton(
              icon: Icon(
                Icons.delete_rounded,
                color: black,
              ),
              onPressed: onDelete,
            ),
          ),
        ));
  }
}
