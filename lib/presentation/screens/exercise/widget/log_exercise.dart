import 'package:flutter/material.dart';
import 'package:grindstone/core/model/log.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:provider/provider.dart';

class LogExerciseModal extends StatefulWidget {
  final String apiId;
  final String exerciseId;

  const LogExerciseModal({
    super.key,
    required this.apiId,
    required this.exerciseId,
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

    setState(() => _isSubmitting = true);

    try {
      final logService = Provider.of<LogService>(context, listen: false);

      final newEntry = DataLog(
        weight: weight,
        reps: reps,
        rir: rir,
        date: DateTime.now().toIso8601String(),
      );

      // id is program id
      // exercise id is from api
      final log = Log(
        id: widget.exerciseId,
        exerciseId: widget.apiId,
        logs: [newEntry],
      );

      final bool didSave = await logService.createLog(log);

      if (didSave) {
        SuccessToast.show('Exercise logged successfully');
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
    // Check if context is still valid
    if (!mounted) return Container();

    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Weight Lifted (kg)"),
          ),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Reps Performed"),
          ),
          TextField(
            controller: rirController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "RIR"),
          ),
          AccentButton(
            onPressed: _logExercise,
            label: 'Log',
          ),
        ],
      ),
    );
  }
}
