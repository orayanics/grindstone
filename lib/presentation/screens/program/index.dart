import 'package:flutter/material.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/program_crud_services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class ProgramIndexView extends StatefulWidget {
  const ProgramIndexView({super.key});

  @override
  State<ProgramIndexView> createState() => _ProgramIndexViewState();
}

class _ProgramIndexViewState extends State<ProgramIndexView> {
  late Future<List<ExerciseProgram>> _exercisesFuture;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  void _loadExercises() {
    final apiCalls = Provider.of<ApiCalls>(context, listen: false);
    _exercisesFuture = apiCalls.fetchUserPrograms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Exercise Programs')),
      body: FutureBuilder<List<ExerciseProgram>>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No exercises found'));
          } else {
            final exercises = snapshot.data!;
            return ListView.builder(
              itemCount: exercises.length,
              itemBuilder: (context, index) {
                final exercise = exercises[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () async {
                      await context.push(
                        '/program-details/${exercise.id}',
                        extra: exercise.exercises,
                      );
                      setState(() {
                        _loadExercises();
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.programName,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text('Day: ${exercise.dayOfExecution}'),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
