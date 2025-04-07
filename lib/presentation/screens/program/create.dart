import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:go_router/go_router.dart';

class CreateProgramView extends StatefulWidget {
  const CreateProgramView({super.key});

  @override
  State<CreateProgramView> createState() => _CreateProgramViewState();
}

class _CreateProgramViewState extends State<CreateProgramView> {
  final _formKey = GlobalKey<FormState>();

  // Input Controllers
  final _programName = TextEditingController();
  final _dayOfExecution = TextEditingController();
  final _searchController = TextEditingController();

  final List<Map<String, String>> _selectedExercises = [];
  List<Map<String, String>> _searchResults = [];

  Future<void> _fetchExercises(String query) async {
    try {
      final results = await ExerciseApi.fetchSearch(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      FailToast.show('Failed to get exercises');
    }
  }

  void _addExercise(Map<String, String> exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _deleteExercise(Map<String, String> exercise) {
    setState(() {
      _selectedExercises.remove(exercise);
    });
  }

  Future<void> _submitProgram() async {
    if (_formKey.currentState!.validate()) {
      final program = ExerciseProgram(
        id: Uuid().v4(),
        userId: FirebaseAuth.instance.currentUser!.uid,
        programName: _programName.text,
        dayOfExecution: _dayOfExecution.text,
        exercises: _selectedExercises,
      );

      // Use ProgramProvider to create the program
      final programProvider =
          Provider.of<ProgramService>(context, listen: false);

      await programProvider.createProgram(program);

      if (programProvider.errorMessage != null) {
        FailToast.show(programProvider.errorMessage!);
      } else {
        SuccessToast.show('Program created successfully!');
        if (mounted) {
          context.go(AppRoutes.programs);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final programProvider = Provider.of<ProgramService>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Create Exercise Program')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _programName,
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
                value: _dayOfExecution.text.isNotEmpty
                    ? _dayOfExecution.text
                    : null,
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
                    _dayOfExecution.text = value!;
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
                controller: _searchController,
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
              if (programProvider.isLoading)
                CircularProgressIndicator()
              else
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
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deleteExercise(exercise),
                      ),
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
