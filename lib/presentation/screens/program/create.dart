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
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_session.dart';

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

  // State variables
  final List<Map<String, String>> _selectedExercises = [];
  List<Map<String, String>> _searchResults = [];
  bool _isSubmitting = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _programName.dispose();
    _dayOfExecution.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
        FailToast.show('You must be logged in to create programs');
        context.go(AppRoutes.login);
      }
    });
  }

  Future<void> _fetchExercises(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await ExerciseApi.fetchSearch(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        FailToast.show('Failed to get exercises');
      }
    }
  }

  void _addExercise(Map<String, String> exercise) {
    if (_selectedExercises
        .any((item) => item['exerciseId'] == exercise['exerciseId'])) {
      FailToast.show('This exercise is already added');
      return;
    }

    setState(() {
      _selectedExercises.add(exercise);
    });

    SuccessToast.show('Exercise added to program');
  }

  void _deleteExercise(Map<String, String> exercise) {
    setState(() {
      _selectedExercises.remove(exercise);
    });
  }

  Future<void> _submitProgram() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedExercises.isEmpty) {
        FailToast.show('Please add at least one exercise to your program');
        return;
      }

      setState(() {
        _isSubmitting = true;
      });

      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
        setState(() {
          _isSubmitting = false;
        });
        FailToast.show('You must be logged in to create programs');
        context.go(AppRoutes.login);
        return;
      }

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isSubmitting = false;
        });
        FailToast.show('User authentication error');
        return;
      }

      final program = ExerciseProgram(
        id: Uuid().v4(),
        userId: currentUser.uid,
        programName: _programName.text,
        dayOfExecution: _dayOfExecution.text,
        exercises: _selectedExercises,
      );

      final programProvider =
          Provider.of<ProgramService>(context, listen: false);

      try {
        final success = await programProvider.createProgram(program);

        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }

        if (!success) {
          FailToast.show(
              programProvider.errorMessage ?? 'Failed to create program');
        } else {
          SuccessToast.show('Program created successfully!');
          if (mounted) {
            context.go(AppRoutes.programs);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
          FailToast.show('Error creating program: $e');
        }
      }
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Program name field
              TextFormField(
                controller: _programName,
                decoration: InputDecoration(
                  labelText: 'Program Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.fitness_center),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a program name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Day of execution dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Day of Execution',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.calendar_today),
                ),
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
              SizedBox(height: 16),

              // Search bar for exercises
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Exercises',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: _isSearching
                      ? Container(
                          width: 24,
                          height: 24,
                          padding: EdgeInsets.all(8),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                onChanged: (value) async {
                  await _fetchExercises(value);
                },
              ),
              SizedBox(height: 8),

              // Search results
              Text(
                'Search Results',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                flex: 2,
                child: _searchResults.isEmpty && _searchController.text.isEmpty
                    ? Center(child: Text('Type to search for exercises'))
                    : _searchResults.isEmpty
                        ? Center(child: Text('No exercises found'))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final exercise = _searchResults[index];

                              final bool isAlreadyAdded =
                                  _selectedExercises.any((item) =>
                                      item['exerciseId'] ==
                                      exercise['exerciseId']);

                              return Card(
                                child: ListTile(
                                  title: Text(exercise['name']!),
                                  trailing: IconButton(
                                    icon: Icon(isAlreadyAdded
                                        ? Icons.check_circle
                                        : Icons.add_circle),
                                    color: isAlreadyAdded ? Colors.green : null,
                                    onPressed: isAlreadyAdded
                                        ? null
                                        : () => _addExercise(exercise),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
              SizedBox(height: 8),

              // Selected exercises
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Selected Exercises',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text('${_selectedExercises.length} exercises selected'),
                ],
              ),
              Expanded(
                flex: 2,
                child: _selectedExercises.isEmpty
                    ? Center(child: Text('No exercises selected yet'))
                    : ListView.builder(
                        itemCount: _selectedExercises.length,
                        itemBuilder: (context, index) {
                          final exercise = _selectedExercises[index];
                          return Card(
                            child: ListTile(
                              title: Text(exercise['name']!),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteExercise(exercise),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              SizedBox(height: 16),

              // Submit button
              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Create Program',
                      onPressed: _submitProgram,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
