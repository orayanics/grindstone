import 'package:flutter/material.dart';
import 'package:grindstone/core/model/log.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/services/program_service.dart';

class LogExerciseModal extends StatefulWidget {
  final String apiId;
  final String exerciseId;
  final String? programId;
  final VoidCallback? onLogSuccess;

  const LogExerciseModal({
    super.key,
    required this.apiId,
    required this.exerciseId,
    required this.programId,
    this.onLogSuccess,
  });

  @override
  State<LogExerciseModal> createState() => _LogExerciseModalState();
}

class _LogExerciseModalState extends State<LogExerciseModal> {
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final rirController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    rirController.dispose();
    super.dispose();
  }

  Future<void> _logExercise() async {
    if (!mounted) return;

    final weight = int.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final rir = int.tryParse(rirController.text.trim());

    if (weight == null || reps == null || rir == null) {
      FailToast.show('Please enter valid weight, reps, and RIR');
      return;
    }

    // TODO: Refactor
    String action = "No Logs Found";

    if (reps >= 7 && rir >= 1) {
      action = 'Increase';
    } else if (reps >= 7 && rir == 0) {
      action = 'Maintain';
    } else if (reps == 6 && rir == 0) {
      action = 'Maintain';
    } else if (reps == 6 && rir >= 1) {
      action = 'Increase';
    } else if (reps == 5 && rir == 0) {
      action = 'Maintain';
    } else if (reps == 5 && rir >= 1) {
      action = 'Increase';
    } else if (reps == 4 && rir == 0) {
      action = 'Maintain';
    } else if (reps == 4 && rir >= 1) {
      action = 'Increase';
    } else if (reps <= 3 && rir == 0) {
      action = 'Decrease';
    } else if (reps <= 3 && rir >= 1) {
      action = 'Decrease';
    }

    setState(() => _isSubmitting = true);

    try {
      final logService = Provider.of<LogService>(context, listen: false);
      final programService =
          Provider.of<ProgramService>(context, listen: false);

      final newEntry = DataLog(
        weight: weight,
        reps: reps,
        rir: rir,
        action: action,
        date: DateTime.now().toIso8601String(),
      );

      final log = Log(
        id: widget.exerciseId,
        exerciseId: widget.apiId,
        logs: [newEntry],
      );

      final bool didSave = await logService.createLog(log);

      if (didSave) {
        if (widget.programId != null) {
          final lastUpdated = DateTime.now().toIso8601String();
          programService.updateLastUpdated(widget.programId!, lastUpdated);
        } else {
          FailToast.show('Program ID is missing');
        }
        SuccessToast.show('Exercise logged successfully');
        widget.onLogSuccess?.call();
        Navigator.of(context).pop();
      } else {
        FailToast.show('Failed to log exercise');
      }
    } catch (e) {
      FailToast.show('Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 1,
      title: Text(
        "Log Exercise",
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: accentRed,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              text: "Weight Lifted (kg) ",
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: accentRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final currentValue =
                      int.tryParse(_weightController.text) ?? 0;
                  _weightController.text =
                      (currentValue > 0 ? currentValue - 1 : 0).toString();
                },
              ),
              Expanded(
                child: TextField(
                  controller: _weightController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final currentValue =
                      int.tryParse(_weightController.text) ?? 0;
                  _weightController.text = (currentValue + 1).toString();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: "Reps Performed ",
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: accentRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final currentValue = int.tryParse(_repsController.text) ?? 0;
                  _repsController.text =
                      (currentValue > 0 ? currentValue - 1 : 0).toString();
                },
              ),
              Expanded(
                child: TextField(
                  controller: _repsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final currentValue = int.tryParse(_repsController.text) ?? 0;
                  _repsController.text = (currentValue + 1).toString();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              text: "RIR ",
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: "*",
                  style: TextStyle(color: accentRed),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  final currentValue = int.tryParse(rirController.text) ?? 0;
                  rirController.text =
                      (currentValue > 0 ? currentValue - 1 : 0).toString();
                },
              ),
              Expanded(
                child: TextField(
                  controller: rirController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '0',
                    filled: true,
                    fillColor: lightGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  final currentValue = int.tryParse(rirController.text) ?? 0;
                  rirController.text = (currentValue + 1).toString();
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: AccentButton(
            onPressed: _logExercise,
            label: _isSubmitting
                ? const CircularProgressIndicator(
                    color: white,
                  )
                : 'Log',
          ),
        ),
      ],
    );
  }
}
