import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/model/exercise.dart';
import 'package:grindstone/core/model/log.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widget/log_exercise.dart';

class ExerciseDetailsView extends StatelessWidget {
  final String exerciseId;
  final String programId;

  const ExerciseDetailsView({
    super.key,
    required this.exerciseId,
    required this.programId,
  });

  @override
  Widget build(BuildContext context) {
    final state = GoRouter.of(context).routerDelegate.currentConfiguration;
    final extraData = state.extra as List<String>?;
    final exerciseId =
        extraData != null && extraData.isNotEmpty ? extraData[0] : null;
    final programId =
        extraData != null && extraData.isNotEmpty ? extraData[1] : null;

    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: white,
        ),
        child: Column(
          children: [
            ExerciseDetails(exerciseId: exerciseId ?? ''),
            ExerciseLogs(exerciseId: exerciseId ?? ''),
          ],
        ));
  }
}

// stateful widget for exercise logs
class ExerciseLogs extends StatefulWidget {
  final String programId;

  const ExerciseLogs({super.key, required this.programId});

  @override
  State<ExerciseLogs> createState() => _ExerciseLogsState();
}

class _ExerciseLogsState extends State<ExerciseLogs> {
  List<Log> _logs = [];
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
      final logs = await logService.fetchLogsByProgram(
          programId: widget.programId, limit: 10);
      setState(() {
        _logs =
            logs?.logs != null ? List<Log>.from(logs!.logs as List) : <Log>[];
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
    return Container(
      child: Column(
        children: [
          Text('Exercise Logs'),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!))
          else
            ListView.builder(
              itemCount: _logs.length,
              itemBuilder: (context, index) {
                return Container(
                  child: Column(
                    children: [
                      Text(_logs[index].logs.isNotEmpty
                          ? _logs[index].logs[0].date
                          : ''),
                      Text(_logs[index].logs.isNotEmpty
                          ? _logs[index].logs[0].weight.toString()
                          : ''),
                      Text(_logs[index].logs.isNotEmpty
                          ? _logs[index].logs[0].reps.toString()
                          : ''),
                      Text(_logs[index].logs.isNotEmpty
                          ? _logs[index].logs[0].rir.toString()
                          : ''),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
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
      print('exerciseId: ${widget.exerciseId}');
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

    return Container(
      child: Column(
        children: [
          ExerciseDetailsHeader(
            exerciseName: _exercise?['name'] ?? '',
            lastUpdated: 'Last Updated',
          ),
          ExerciseDetailsBody(
            gifUrl: _exercise?['gifUrl'] ?? '',
            muscleGroups: _exercise?['muscleGroups'] != null
                ? List<String>.from(_exercise!['muscleGroups'] as List)
                : <String>[],
            exerciseDetails: _exercise?['exerciseDetails'] != null
                ? List<String>.from(_exercise!['exerciseDetails'] as List)
                : <String>[],
            instructions: _exercise?['instructions'] != null
                ? List<String>.from(_exercise!['instructions'] as List)
                : <String>[],
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailsBody extends StatelessWidget {
  final String gifUrl;
  final List<String> muscleGroups;
  final List<String> exerciseDetails;
  final List<String> instructions;

  const ExerciseDetailsBody(
      {super.key,
      required this.gifUrl,
      required this.muscleGroups,
      required this.exerciseDetails,
      required this.instructions});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          gifUrl.isNotEmpty
              ? Image.network(
                  gifUrl,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Text('Image not available')),
                    );
                  },
                )
              : const SizedBox(
                  height: 200,
                  child: Center(child: Text('No image available')),
                ),
          Text(muscleGroups.isNotEmpty
              ? muscleGroups.join(', ')
              : 'No muscle groups specified'),
          Text(exerciseDetails.isNotEmpty
              ? exerciseDetails.join(', ')
              : 'No details available'),
          Text(instructions.isNotEmpty
              ? instructions.join(', ')
              : 'No instructions available'),
          const SizedBox(height: 16),
        ],
      ),
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
