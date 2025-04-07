import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _fetchExercises();
  }

  Future<ExerciseProgram?> _fetchExercises() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    return await programService.fetchProgramById(widget.programId);
  }

  void _refreshExercises() {
    if (mounted) {
      setState(() {
        _exercisesFuture = _fetchExercises();
      });
    }
  }

  void _deleteProgram() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Program',
              content:
                  'Are you sure to delete this program ${widget.programName}?',
              onDelete: () async {
                try {
                  await programService.deleteProgram(widget.programId);
                  if (mounted) {
                    Navigator.pop(context);
                    context.go(AppRoutes.programs);
                    SuccessToast.show('Program deleted successfully');
                  }
                } catch (e) {
                  Navigator.pop(context);
                  FailToast.show('Failed to delete program');
                }
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  void _deleteExercise(String exerciseId) async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Exercise',
              content: 'Are you sure to delete this exercise?',
              onDelete: () async {
                log('oraya delete: ${widget.programId} and exerid $exerciseId');
                await programService.deleteExercise(
                    widget.programId, exerciseId);
                if (mounted) {
                  Navigator.pop(context);
                  _refreshExercises();
                  SuccessToast.show('Exercise deleted successfully');
                }
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.programName)),
      body: FutureBuilder<ExerciseProgram?>(
        future: _exercisesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Program not found'));
          } else {
            final program = snapshot.data!;
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: program.exercises.length,
                    itemBuilder: (context, index) {
                      final exercise = program.exercises[index];
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(exercise['name'] ?? 'Unnamed Exercise'),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () =>
                                _deleteExercise(exercise['exerciseId']!),
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
                                    _refreshExercises();
                                  });
                            },
                          );
                        },
                        child: Text('Update'),
                      ),
                      ElevatedButton(
                        onPressed: _deleteProgram,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
        },
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

  Future<void> _addExercisesToProgram() async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    try {
      await programService.addExerciseToProgram(
          widget.programId, _selectedExercises);

      if (mounted) {
        Navigator.pop(context);
      }
      widget.onUpdate();
      SuccessToast.show('Exercises added to program');
    } catch (e) {
      FailToast.show('Failed to update program');
    }
  }

  Future<void> _fetchSearchResults(String query) async {
    try {
      final results = await ExerciseApi.fetchSearch(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
        });
      }
    } catch (e) {
      if (mounted) {
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
          Text('Add Exercises'),
          TextField(
            decoration: InputDecoration(
              labelText: 'Exercise Name',
            ),
            onChanged: (value) async {
              await _fetchSearchResults(value);
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
          Expanded(
            child: ListView.builder(
              itemCount: _selectedExercises.length,
              itemBuilder: (context, index) {
                final exercise = _selectedExercises[index];
                return ListTile(
                  title: Text(exercise['name']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteExercise(exercise['exerciseId']!),
                  ),
                );
              },
            ),
          ),
          PrimaryButton(
              label: 'Add New Exercises',
              onPressed: () {
                _addExercisesToProgram();
              })
        ],
      ),
    )));
  }
}
