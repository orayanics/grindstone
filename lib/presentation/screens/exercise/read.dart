import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:provider/provider.dart';
import 'widget/log_exercise.dart';

class ExerciseDetailsView extends StatelessWidget {
  final String apiId;
  final String exerciseId;
  final String programId;

  ExerciseDetailsView({
    super.key,
    required this.apiId,
    required this.exerciseId,
    required this.programId,
  });

  final GlobalKey<_ExerciseLogsState> _logsKey =
      GlobalKey<_ExerciseLogsState>();

  @override
  Widget build(BuildContext context) {
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
              ExerciseLogs(
                key: _logsKey,
                exerciseId: exerciseId,
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return LogExerciseModal(
                apiId: apiId,
                exerciseId: exerciseId,
                programId: programId,
                onLogSuccess: () {
                  _logsKey.currentState?._fetchExerciseLogs();
                },
              );
            },
          );
        },
        backgroundColor: accentPurple,
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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

      final logs = await logService.fetchLogById(widget.exerciseId);

      setState(() {
        _logs = logs;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen =
            constraints.maxWidth > 600; // Adjust breakpoint as needed

        return Column(
          crossAxisAlignment: isLargeScreen
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Align(
                alignment:
                    isLargeScreen ? Alignment.center : Alignment.centerLeft,
                child: Text(
                  'Latest Log',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: isLargeScreen ? TextAlign.center : TextAlign.start,
                )),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(child: Text(_error!))
            else if (_logs.isEmpty)
              const Text('No logs available')
            else
              Wrap(
                spacing: 16.0,
                runSpacing: 12.0,
                children: _logs.map((log) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogItem('${log.weight} kg'),
                      const SizedBox(width: 8),
                      _buildLogItem('${log.reps} reps'),
                      const SizedBox(width: 8),
                      _buildLogItem('${log.rir} RIR'),
                      const SizedBox(width: 8),
                      _buildLogItem(log.action),
                    ],
                  );
                }).toList(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildLogItem(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: accentPurple,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        text,
        style: const TextStyle(color: white),
      ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLargeScreen =
            constraints.maxWidth > 600; // Adjust breakpoint as needed

        return Column(
          crossAxisAlignment: isLargeScreen
              ? CrossAxisAlignment.center // Center for larger screens
              : CrossAxisAlignment.start, // Left-align for smaller screens
          children: [
            Center(
              child: Card(
                color: white,
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow these steps to perform the exercise:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textLight,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        instructions
                            .asMap()
                            .entries
                            .map((entry) {
                              final stepNumber = entry.key + 1;
                              final instruction = entry.value.trim();
                              return instruction.replaceAll(
                                  'Step:$stepNumber', 'Step $stepNumber:');
                            })
                            .join('\n')
                            .replaceAll('[', '')
                            .replaceAll(']', ''),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: textLight,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Target Muscles',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: isLargeScreen ? TextAlign.center : TextAlign.start,
            ),
            const SizedBox(height: 8),
            Wrap(
              alignment: isLargeScreen
                  ? WrapAlignment.center // Center chips for larger screens
                  : WrapAlignment.start, // Left-align chips for smaller screens
              spacing: 8.0,
              runSpacing: 8.0,
              children: [
                ...bodyParts.map((part) => _buildOutlinedChip(
                    part.replaceAll('[', '').replaceAll(']', ''))),
                ...targetMuscles.map((muscle) => _buildOutlinedChip(
                    muscle.replaceAll('[', '').replaceAll(']', ''))),
                ...secondaryMuscles.map((muscle) => _buildOutlinedChip(
                    muscle.replaceAll('[', '').replaceAll(']', ''))),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildOutlinedChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: accentRed, width: 1.5),
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Text(
        label,
        style: TextStyle(color: accentRed),
      ),
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
        const SizedBox(height: 16),
      ],
    );
  }
}
