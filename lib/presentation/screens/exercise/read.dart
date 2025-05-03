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

    return Scaffold(
      backgroundColor: white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExerciseDetails(exerciseId: apiId),
              const SizedBox(height: 20),
              ExerciseLogs(exerciseId: exerciseId),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) {
                        return LogExerciseModal(
                          apiId: apiId,
                          exerciseId: exerciseId,
                        );
                      },
                    );
                  },
                  child: const Text('Log Exercise'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
      print('Fetching logs for exerciseId: ${widget.exerciseId}');

      final logs = await logService.fetchLogById(widget.exerciseId);
      print('Fetched logs: $logs');

      setState(() {
        _logs = logs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching logs: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Exercise Logs', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Center(child: Text(_error!))
        else if (_logs.isEmpty)
            const Text('No logs available')
          else
            ..._logs.map((log) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight: ${log.weight}'),
                      Text('Reps: ${log.reps}'),
                      Text('RIR: ${log.rir}'),
                      Text('Action: ${log.action}'),
                      Text('Date: ${Date.parseDate(log.date)}'),
                    ],
                  ),
                ),
              );
            }),
      ],
    );
  }
}

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
      crossAxisAlignment: CrossAxisAlignment.start,
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

  const ExerciseDetailsBody({
    super.key,
    required this.bodyParts,
    required this.targetMuscles,
    required this.secondaryMuscles,
    required this.instructions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Body Parts: ${bodyParts.join(', ')}'),
        Text('Target Muscles: ${targetMuscles.join(', ')}'),
        Text('Secondary Muscles: ${secondaryMuscles.join(', ')}'),
        const SizedBox(height: 10),
        Text('Instructions:', style: Theme.of(context).textTheme.titleMedium),
        ...instructions.map((instruction) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              instruction.trim(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textLight,
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 16),
      ],
    );
  }
}

class ExerciseDetailsHeader extends StatelessWidget {
  final String exerciseName;
  final String lastUpdated;

  const ExerciseDetailsHeader({
    super.key,
    required this.exerciseName,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          exerciseName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
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
      ],
    );
  }
}
