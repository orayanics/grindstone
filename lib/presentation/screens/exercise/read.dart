import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/utils/date.dart';
import 'package:provider/provider.dart';

import 'widget/log_exercise.dart';

class ExerciseDetailsView extends StatelessWidget {
  final String apiId;
  final String exerciseId;

  const ExerciseDetailsView({
    super.key,
    required this.apiId,
    required this.exerciseId,
  });

  @override
  Widget build(BuildContext context) {
    final state = GoRouter.of(context).routerDelegate.currentConfiguration;
    final apiId = state.pathParameters['apiId'] ?? '';
    final exerciseId = state.pathParameters['exerciseId'] ?? '';

    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: white,
        ),
        child: Column(
          children: [
            ExerciseDetails(exerciseId: apiId),
            ExerciseLogs(
              exerciseId: exerciseId,
            ),
            ElevatedButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return LogExerciseModal(
                      apiId: apiId,
                      exerciseId: exerciseId,
                    );
                  },
                );
              },
              child: const Text('Log Exercise'),
            )
          ],
        ));
  }
}

// stateful widget for exercise logs
class ExerciseLogs extends StatefulWidget {
  final String exerciseId;
  const ExerciseLogs({super.key, required this.exerciseId});

  @override
  State<ExerciseLogs> createState() => _ExerciseLogsState();
}

class _ExerciseLogsState extends State<ExerciseLogs> {
  List<DataLog> _logs = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExerciseLogs();
  }

  Future<void> _fetchExerciseLogs() async {
    try {
      final logService = Provider.of<LogService>(context, listen: false);
      final logs = await logService.fetchLogById(widget.exerciseId);

      setState(() {
        if (logs.isEmpty) {
          _logs = [];
        } else {
          _logs = logs;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Exercise Logs'),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(child: Text(_error!))
        else
          Column(
            children: [
              if (_logs.isEmpty)
                const Text('No logs available')
              else
                ..._logs.map((log) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight: ${log.weight}'),
                      Text('Reps: ${log.reps}'),
                      Text('RIR: ${log.rir}'),
                      Text('Date: ${Date.parseDate(log.date)}'),
                    ],
                  );
                })
            ],
          ),
      ],
    );
  }
}

// stateful widget for exercise details
class ExerciseDetails extends StatefulWidget {
  final String exerciseId;

  const ExerciseDetails({super.key, required this.exerciseId});

  @override
  State<ExerciseDetails> createState() => _ExerciseDetailsState();
}

class _ExerciseDetailsState extends State<ExerciseDetails> {
  Map<String, String>? _exercise;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchExerciseDetails();
  }

  Future<void> _fetchExerciseDetails() async {
    try {
      final exercise = await ExerciseApi.fetchExerciseById(widget.exerciseId);
      setState(() {
        _exercise = exercise;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text(_error!));
    }

    return Column(
      children: [
        ExerciseDetailsHeader(
          exerciseName: _exercise?['name'] ?? '',
          lastUpdated: 'Last Updated',
        ),
        ExerciseDetailsBody(
          bodyParts: _exercise?['bodyParts']?.split(',') ?? [],
          targetMuscles: _exercise?['targetMuscles']?.split(',') ?? [],
          secondaryMuscles: _exercise?['secondaryMuscles']?.split(',') ?? [],
          instructions: _exercise?['instructions']?.split(',') ?? [],
        ),
      ],
    );
  }
}

class ExerciseDetailsBody extends StatelessWidget {
  final List<String> bodyParts;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  const ExerciseDetailsBody(
      {super.key,
      required this.bodyParts,
      required this.targetMuscles,
      required this.secondaryMuscles,
      required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            'Body Parts: ${bodyParts.join(', ').replaceAll('[', '').replaceAll(']', '')}'),
        Text(
            'Target Muscles: ${targetMuscles.join(', ').replaceAll('[', '').replaceAll(']', '')}'),
        Text(
            'Secondary Muscles: ${secondaryMuscles.join(', ').replaceAll('[', '').replaceAll(']', '')}'),
        Text('Instructions:'),
        ...instructions.map((instruction) {
          return Text(instruction.replaceAll('[', '').replaceAll(']', ''),
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: textLight,
                  ));
        }),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ExerciseDetailsHeader extends StatelessWidget {
  final String exerciseName;
  final String lastUpdated;

  const ExerciseDetailsHeader(
      {super.key, required this.exerciseName, required this.lastUpdated});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        exerciseName,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Last Update ',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: accentPurple,
                  ),
            ),
            TextSpan(
              text: 'on $lastUpdated',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: textLight,
                  ),
            ),
          ],
        ),
      ),
      const Divider(),
      Text(
        'Follow along the instructions!',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: textLight,
            ),
      ),
      const SizedBox(height: 16),
    ]);
  }
}

class ExerciseDetailsContainer extends StatelessWidget {
  const ExerciseDetailsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: white,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const Text('Home')],
          ),
        ),
      ),
    );
  }
}
