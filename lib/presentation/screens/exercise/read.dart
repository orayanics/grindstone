import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/model/exercise.dart';
import 'package:grindstone/core/services/user_session.dart';
import 'package:go_router/go_router.dart';


import '../../components/modal/log_exercise.dart';

class ExerciseDetails extends StatelessWidget {
  final String exerciseId;

  const ExerciseDetails({super.key, required this.exerciseId,});

  @override
  Widget build(BuildContext context) {
    final state = GoRouter.of(context).routerDelegate.currentConfiguration;
    final programId = state?.extra as String?;

    if (programId == null) {
      return const Scaffold(
        body: Center(child: Text('Program ID not found')),
      );
    }
    return FutureBuilder<Map<String, String>>(
      future: ExerciseApi.fetchExerciseById(exerciseId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Exercise not found')),
          );
        }

        final exerciseData = snapshot.data!;
        final exercise = Exercise(
          programId: programId?? '',
          id: exerciseData['exerciseId'] ?? '',
          name: exerciseData['name'] ?? '',
          gifUrl: exerciseData['gifUrl'] ?? '',
          instructions: (exerciseData['instructions'] ?? '').split(','),
          targetMuscles: (exerciseData['targetMuscles'] ?? '').split(','),
          secondaryMuscles: (exerciseData['secondaryMuscles'] ?? '').split(','),
          bodyParts: (exerciseData['bodyParts'] ?? '').split(','),
          equipments: (exerciseData['equipments'] ?? '').split(','),
        );

        return Scaffold(body: ExerciseDetailsView(exercise: exercise , programId: programId,));
      },
    );
  }
}

class ExerciseDetailsView extends StatelessWidget {
  final Exercise exercise;
  final String programId;
  const ExerciseDetailsView({super.key, required this.exercise, required this.programId});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ExerciseDetailsHeader(
            exerciseName: exercise.name,
            lastUpdated: 'Last Updated',
          ),

          // TODO: Get from exercises based on exerciseProgram id
          // then in exercises node, get the exerciseId
          // response from api contains
          // exerciseId, name, gifUrl, instructions, targetMuscles, secondaryMuscles, bodyParts
          ExerciseDetailsBody(
            programId: exercise.programId,
            exerciseId: exercise.id,
            gifUrl: exercise.gifUrl,
            muscleGroups: exercise.targetMuscles + exercise.secondaryMuscles,
            exerciseDetails: exercise.bodyParts,
            instructions: exercise.instructions,
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailsBody extends StatelessWidget {
  final String gifUrl;
  final String programId;
  final String exerciseId;
  final List<String> muscleGroups;
  final List<String> exerciseDetails;
  final List<String> instructions;

  const ExerciseDetailsBody(
      {super.key,
      required this.gifUrl,
      required this.muscleGroups,
      required this.exerciseDetails,
      required this.instructions,
      required this.programId,
      required this.exerciseId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Image.network(gifUrl),
          Text(muscleGroups.join(', ')),
          Text(exerciseDetails.join(', ')),
          Text(instructions.join(', ')),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {

              print('Program ID: $programId');
              print('Exercise ID: $exerciseId');

              showDialog(
                context: context,
                builder: (context) => LogExerciseModal(
                  programId: programId, // Pass the programId dynamically
                  exerciseId: exerciseId, // Pass the exerciseId dynamically
                ),
              );
            },
            child: Text("Log Session"),
          ),
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
