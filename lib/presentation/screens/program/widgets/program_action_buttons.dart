import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class ProgramActionButtons extends StatelessWidget {
  final String programId;
  final VoidCallback onDeleteProgram;
  final VoidCallback onUpdateExercises;

  const ProgramActionButtons({
    super.key,
    required this.programId,
    required this.onDeleteProgram,
    required this.onUpdateExercises,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              elevation: 0,
              backgroundColor: accentPurple,
              heroTag: "addExercises",
              onPressed: onUpdateExercises,
              child: Icon(
                Icons.add_rounded,
                color: white,
              ),
            ),
            SizedBox(height: 16.0),
            FloatingActionButton(
              elevation: 0,
              backgroundColor: accentPurple,
              heroTag: "deleteProgram",
              onPressed: onDeleteProgram,
              child: Icon(
                Icons.delete_rounded,
                color: white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
