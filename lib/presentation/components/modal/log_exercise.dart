import 'package:flutter/material.dart';
import 'package:grindstone/core/services/log_service.dart';
import 'package:grindstone/core/exports/components.dart';

class LogExerciseModal extends StatefulWidget {
  final String programId;
  final String exerciseId;


  const LogExerciseModal({
    super.key,
    required this.programId,
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


    final weight = int.tryParse(_weightController.text.trim());
    final reps = int.tryParse(_repsController.text.trim());
    final rir = int.tryParse(rirController.text.trim());

    if (weight == null || reps == null || rir == null) {
      FailToast.show('Please enter valid weight, reps, and RIR');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {

      await LogService().logExercise(
        programId: widget.programId,
        exerciseId: widget.exerciseId,
        weight: weight,
        reps: reps,
        rir: rir,
      );

      if (mounted) {
        Navigator.of(context).pop();
        SuccessToast.show('Exercise logged successfully');
      }
    } catch (e) {
      FailToast.show('Failed to log exercise: $e');
    }
    finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Log Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Weight Lifted (kg)"),
          ),
          TextField(
            controller: _repsController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "Reps Performed"),
          ),
          TextField(
            controller: rirController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: "RIR"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _logExercise,
          child: _isSubmitting
              ? CircularProgressIndicator()
              : Text('Log'),
        ),
      ],
    );
  }
}
