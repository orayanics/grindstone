import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:uuid/uuid.dart';

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

  // TODO: move to auth service or improve
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
    final String id = Uuid().v4();
    setState(() {
      _selectedExercises.add({...exercise,'id': id});
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

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);

      if (success) {
        widget.onUpdate();
        SuccessToast.show('Exercises added to program');
      } else {
        FailToast.show(
            programService.errorMessage ?? 'Failed to update program');
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

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
      if (!mounted) return;

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
      FailToast.show('Failed to get exercises');
    }
  }

  @override
Widget build(BuildContext context) {
  return Center(
    child: Dialog(
      backgroundColor: white, // Set the background color to white
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
              // Set the button color to accentPurple
            )
          ],
        ),
      ),
    ),
  );
}
}

