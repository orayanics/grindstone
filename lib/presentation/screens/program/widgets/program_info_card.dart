import 'package:flutter/material.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/config/colors.dart';

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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.programName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Last Update ',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: accentPurple,
                                  ),
                        ),
                        TextSpan(
                          text: 'on ${program.dayOfExecution}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: textLight,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),
              Text(
                'These are your exercises for the program.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: textLight,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
