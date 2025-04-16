import 'package:flutter/material.dart';
import 'package:grindstone/core/model/exercise_program.dart';

class ProgramInfoCard extends StatelessWidget {
  final ExerciseProgram program;

  const ProgramInfoCard({
    super.key,
    required this.program,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      program.programName,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                  Chip(
                    label: Text('Day: ${program.dayOfExecution}'),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Exercises',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${program.exercises.length}',
                    style: const TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
