import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:uuid/uuid.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/program_crud_services.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/api/exercise_api.dart';

class CreateProgramView extends StatefulWidget {
  const CreateProgramView({super.key});

  @override
  State<CreateProgramView> createState() => _CreateProgramViewState();
}

class _CreateProgramViewState extends State<CreateProgramView> {
  final _formKey = GlobalKey<FormState>();
  final _programNameController = TextEditingController();
  final List<String> _exercises = [];
  final List<Map<String, String>> _selectedExercises = [];
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, String>> _searchResults = [];
  String? _selectedDay;

  final _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _fetchExercises(String query) async {
    try {
      final results = await ExerciseApi.fetchExercises(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      FailToast.show('Failed to get exercises');
    }
  }

  void _addExercise(Map<String, String> exercise) {
    setState(() {
      _exercises.add(exercise['exerciseId']!);
      _selectedExercises.add(exercise);
    });
  }

  Future<void> _submitProgram() async {
    if (_formKey.currentState!.validate()) {
      final program = ExerciseProgram(
        id: Uuid().v4(),
        userId: _userId.toString(),
        programName: _programNameController.text,
        dayOfExecution: _selectedDay!,
        exercises: _exercises,
      );
      await _firestoreService.createExerciseProgram(program);
      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          SuccessToast.show('Program created!');
          context.go(AppRoutes.profile);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Exercise Program')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _programNameController,
                decoration: InputDecoration(labelText: 'Program Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a program name';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Day of Execution'),
                value: _selectedDay,
                items: [
                  'Monday',
                  'Tuesday',
                  'Wednesday',
                  'Thursday',
                  'Friday',
                  'Saturday',
                  'Sunday'
                ]
                    .map((day) => DropdownMenuItem(
                          value: day,
                          child: Text(day),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDay = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a day of execution';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Search Exercises'),
                onChanged: (value) async {
                  await _fetchExercises(value);
                },
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final exercise = _searchResults[index];
                    return ListTile(
                      title: Text(exercise['name']!),
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () => _addExercise(exercise),
                      ),
                    );
                  },
                ),
              ),
              PrimaryButton(
                label: 'Create',
                onPressed: _submitProgram,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _selectedExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = _selectedExercises[index];
                    return ListTile(
                      title: Text(exercise['name']!),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
