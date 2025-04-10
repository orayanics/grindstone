import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  const CustomStepper({
    super.key,
    required this.currentStep,
    required this.steps,
    required this.onStepContinue,
    required this.onStepCancel,
  });

  final int currentStep;
  final List<Step> steps;
  final VoidCallback onStepContinue;
  final VoidCallback onStepCancel;

  @override
  Widget build(BuildContext context) {
    return Stepper(
        type: StepperType.horizontal,
        steps: steps,
        currentStep: currentStep,
        onStepContinue: onStepContinue,
        onStepCancel: onStepCancel,
        controlsBuilder: (context, details) {
          return Row(
            children: [
              TextButton(
                onPressed: details.onStepContinue,
                child: const Text('Continue'),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: details.onStepCancel,
                child: const Text('Cancel'),
              ),
            ],
          );
        });
  }
}
