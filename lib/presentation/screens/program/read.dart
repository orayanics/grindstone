import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_session.dart';

class ProgramDetailsView extends StatefulWidget {
  final String programId;
  final String programName;

  const ProgramDetailsView(
      {super.key, required this.programId, required this.programName});

  @override
  State<ProgramDetailsView> createState() {
    return _ProgramDetailsViewState();
  }
}

class _ProgramDetailsViewState extends State<ProgramDetailsView> {
  late Future<ExerciseProgram?> _exercisesFuture;
  bool _isLoading = true;
  String? _errorMessage;
  ExerciseProgram? _program;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadProgram();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
        FailToast.show('You must be logged in to view program details');
        context.go(AppRoutes.login);
      }
    });
  }

  Future<void> _loadProgram() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // initial data
      _exercisesFuture = _fetchProgram();
      _program = await _exercisesFuture;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load program: $e';
        });
      }
    }
  }

  Future<ExerciseProgram?> _fetchProgram() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Authentication required';
      });
      return null;
    }

    final programService = Provider.of<ProgramService>(context, listen: false);
    try {
      return await programService.fetchProgramById(widget.programId);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch program: $e';
      });
      return null;
    }
  }

  Future<void> _refreshProgram() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final programService =
          Provider.of<ProgramService>(context, listen: false);
      _program = await programService.refreshProgram(widget.programId);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to refresh program: $e';
        });
      }
    }
  }

  void _deleteProgram() async {
    final programService = Provider.of<ProgramService>(context, listen: false);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      FailToast.show('You must be logged in to delete programs');
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Program',
              content:
                  'Are you sure to delete this program ${widget.programName}?',
              onDelete: () async {
                try {
                  final success =
                      await programService.deleteProgram(widget.programId);
                  if (mounted) {
                    Navigator.pop(context);
                    if (success) {
                      context.go(AppRoutes.programs);
                      SuccessToast.show('Program deleted successfully');
                    } else {
                      FailToast.show(programService.errorMessage ??
                          'Failed to delete program');
                    }
                  }
                } catch (e) {
                  Navigator.pop(context);
                  FailToast.show('Failed to delete program: $e');
                }
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  void _deleteExercise(String exerciseId) async {
    final programService = Provider.of<ProgramService>(context, listen: false);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      FailToast.show('You must be logged in to delete exercises');
      return;
    }

    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Exercise',
              content: 'Are you sure to delete this exercise?',
              onDelete: () async {
                log('deleting: ${widget.programId} and exerciseId $exerciseId');
                final success = await programService.deleteExercise(
                    widget.programId, exerciseId);
                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _refreshProgram();
                    SuccessToast.show('Exercise deleted successfully');
                  } else {
                    FailToast.show(programService.errorMessage ??
                        'Failed to delete exercise');
                  }
                }
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      return Scaffold(
        appBar: AppBar(title: Text('Program Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('You must be logged in to view program details'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.login),
                child: Text('Go to Login'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.programName)),
      body: RefreshIndicator(
        onRefresh: _refreshProgram,
        child: _isLoading && _program == null
            ? Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text('Error: $_errorMessage'))
                : _program == null
                    ? Center(child: Text('Program not found'))
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _program!.programName,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 8.0),
                                    Text(
                                      'Day: ${_program!.dayOfExecution}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                    SizedBox(height: 4.0),
                                    Text(
                                      'Exercises: ${_program!.exercises.length}',
                                      style: TextStyle(fontSize: 16.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _program!.exercises.length,
                              itemBuilder: (context, index) {
                                final exercise = _program!.exercises[index];
                                return Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(
                                        exercise['name'] ?? 'Unnamed Exercise'),
                                    trailing: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () => _deleteExercise(
                                          exercise['exerciseId']!),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return UpdateProgramExercises(
                                            programId: widget.programId,
                                            onUpdate: () {
                                              _refreshProgram();
                                            });
                                      },
                                    );
                                  },
                                  child: Text('Add Exercises'),
                                ),
                                ElevatedButton(
                                  onPressed: _deleteProgram,
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                  child: Text('Delete Program'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}

class UpdateProgramExercises extends StatefulWidget {
  const UpdateProgramExercises(
      {super.key, required this.programId, required this.onUpdate});
  final String programId;
  final Function onUpdate;

  @override
  State<UpdateProgramExercises> createState() {
    return _UpdateProgramExercisesState();
  }
}

class _UpdateProgramExercisesState extends State<UpdateProgramExercises> {
  final List<Map<String, dynamic>> _selectedExercises = [];
  List<Map<String, String>> _searchResults = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    Future.microtask(() {
      final authService = Provider.of<AuthService>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
        Navigator.pop(context);
        FailToast.show('You must be logged in to update programs');
      }
    });
  }

  void _addExercise(Map<String, String> exercise) {
    setState(() {
      _selectedExercises.add(exercise);
    });
  }

  void _deleteExercise(String exerciseId) {
    setState(() {
      _selectedExercises
          .removeWhere((exercise) => exercise['exerciseId'] == exerciseId);
    });
  }

  Future<void> _addExercisesToProgram() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      FailToast.show('You must be logged in to update programs');
      Navigator.pop(context);
      return;
    }

    if (_selectedExercises.isEmpty) {
      FailToast.show('Please select at least one exercise to add');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await programService.addExerciseToProgram(
          widget.programId, _selectedExercises);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context);
      }

      if (success) {
        widget.onUpdate();
        SuccessToast.show('Exercises added to program');
      } else {
        FailToast.show(
            programService.errorMessage ?? 'Failed to update program');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      FailToast.show('Failed to update program: $e');
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await ExerciseApi.fetchSearch(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        FailToast.show('Failed to get exercises');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Dialog(
          child: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Add Exercises',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Exercises',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) async {
                await _fetchSearchResults(value);
              },
            ),
            SizedBox(height: 8),
            _isLoading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            Expanded(
              child: _searchResults.isEmpty && _searchController.text.isEmpty
                  ? Center(child: Text('Type to search for exercises'))
                  : _searchResults.isEmpty
                      ? Center(child: Text('No exercises found'))
                      : ListView.builder(
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
            Divider(),
            Text(
              'Selected Exercises',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: _selectedExercises.isEmpty
                  ? Center(child: Text('No exercises selected yet'))
                  : ListView.builder(
                      itemCount: _selectedExercises.length,
                      itemBuilder: (context, index) {
                        final exercise = _selectedExercises[index];
                        return ListTile(
                          title: Text(exercise['name'] as String),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteExercise(
                                exercise['exerciseId'] as String),
                          ),
                        );
                      },
                    ),
            ),
            PrimaryButton(
              label: 'Add Exercises',
              onPressed: _addExercisesToProgram,
            )
          ],
        ),
      )),
    );
  }
}
