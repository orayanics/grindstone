import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/api/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/program_crud_services.dart';
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
  late Future<List<Map<String, String>>> _exercisesFuture;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _exercisesFuture = _fetchExercises();
  }

  Future<List<Map<String, String>>> _fetchExercises() async {
    final exercises =
        await _firestoreService.fetchExerciseProgramById(widget.programId);
    List<Map<String, String>> exerciseDetails = [];
    if (mounted) {
      final apiCalls = Provider.of<ApiCalls>(context, listen: false);
      exerciseDetails = await apiCalls.fetchExerciseNameById(exercises);
    }

    return exerciseDetails;
  }

  void _refreshExercises() {
    setState(() {
      _exercisesFuture = _fetchExercises();
    });
  }

  void _deleteProgram() async {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Program',
              content:
                  'Are you sure to delete this program ${widget.programName}',
              onDelete: () {
                _firestoreService.deleteExerciseProgram(widget.programId);
                Navigator.pop(context);
                GoRouter.of(context).pop();
                GoRouter.of(context).go(AppRoutes.programs);
                SuccessToast.show('Program deleted successfully');
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  void _deleteExercise(String exerciseId) async {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete Exercise',
              content: 'Are you sure to delete this exercise?',
              onDelete: () async {
                await _firestoreService.deleteExerciseFromProgram(
                    widget.programId, exerciseId);
                Navigator.pop(context);
                _refreshExercises();
                SuccessToast.show('Exercise deleted successfully');
              },
              onCancel: () {
                Navigator.pop(context);
              });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: FutureBuilder<List<Map<String, String>>>(
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
                      child: ListTile(
                        title: Text(exercise['name']!),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () =>
                              _deleteExercise(exercise['exerciseId']!),
                        ),
                      ),
                    );
                  },
                );
              }
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
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
        ),
      ],
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
  final List<String> _selectedExercises = [];
  final List<Map<String, String>> _displayExercises = [];
  List<Map<String, String>> _searchResults = [];

  final FirestoreService _firestoreService = FirestoreService();

  void _addExercise(Map<String, String> exercise) {
    setState(() {
      _selectedExercises.add(exercise['exerciseId']!);
      _displayExercises.add(exercise);
    });
  }

  void _addExercisesToProgram() async {
    try {
      await _firestoreService.updateProgram(
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
      final results = await ExerciseApi.fetchExercises(query);
      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      FailToast.show('Failed to get exercises');
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
              itemCount: _displayExercises.length,
              itemBuilder: (context, index) {
                final exercise = _displayExercises[index];
                return ListTile(
                  title: Text(exercise['name']!),
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
