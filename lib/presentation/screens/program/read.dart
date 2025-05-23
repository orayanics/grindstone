import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:grindstone/presentation/screens/program/widgets/program_info_card.dart';
import 'package:grindstone/presentation/screens/program/widgets/update_program_exercises.dart';
import 'package:grindstone/presentation/screens/program/widgets/exercise_list_item.dart';
import 'package:grindstone/presentation/screens/program/widgets/program_action_buttons.dart';

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
  String _filterCriteria = 'All'; // Default filter criteria
  String? _searchQuery = ''; // Search query for exercises

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

  Future<void> _confirmDelete(String type, String exerciseId) async {
    final programService = Provider.of<ProgramService>(context, listen: false);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      FailToast.show('You must be logged in to perform this action.');
      return;
    }
    bool success = false;

    setState(() {
      _isLoading = true;
    });

    if (type == 'program') {
      success = await programService.deleteProgram(widget.programId);
    } else if (type == 'exercise') {
      success =
      await programService.deleteExercise(widget.programId, exerciseId);
    }

    if (!mounted) return;

    if (success) {
      GoRouter.of(context).pop();
      if (type == 'program') {
        GoRouter.of(context).go(AppRoutes.programs);
      } else {
        await _refreshProgram();
      }
      SuccessToast.show('Deleted successfully');
    } else {
      FailToast.show(programService.errorMessage ?? 'Failed to delete');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showDeleteDialog(String type, String exerciseId) {
    showDialog(
        context: context,
        builder: (context) {
          return ConfirmDeleteDialog(
              title: 'Delete $type',
              content: 'Are you sure to delete this $type?',
              onDelete: () {
                _confirmDelete(type, exerciseId);
              },
              onCancel: () {
                GoRouter.of(context).pop();
              });
        });
  }

  void _onFilterChanged(String? value) {
    setState(() {
      _filterCriteria = value ?? 'All'; // Update the filter criteria
    });
  }

  List<Map<String, dynamic>> _getFilteredExercises() {
    List<Map<String, dynamic>> filteredExercises = _program!.exercises;

    if (_filterCriteria != 'All') {
      filteredExercises = filteredExercises
          .where((exercise) =>
      exercise['type']?.toLowerCase() == _filterCriteria.toLowerCase())
          .toList();
    }

    if (_searchQuery != null && _searchQuery!.isNotEmpty) {
      filteredExercises = filteredExercises
          .where((exercise) => exercise['name']
          .toLowerCase()
          .contains(_searchQuery!.toLowerCase()))
          .toList();
    }

    return filteredExercises;
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      return _buildUnauthenticatedView();
    }

    return RefreshIndicator(
      onRefresh: _refreshProgram,
      child: _isLoading && _program == null
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text('Error: $_errorMessage'))
          : _program == null
          ? Center(child: Text('Program not found'))
          : _buildProgramContent(),
    );
  }

  Widget _buildUnauthenticatedView() {
    return Center(
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
    );
  }

  Widget _buildProgramContent() {
    return Stack(
      children: [
        Column(
          children: [
            ProgramInfoCard(program: _program!),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  /*DropdownButton<String>(
                    value: _filterCriteria,
                    onChanged: _onFilterChanged,
                    items: <String>['All', 'Cardio', 'Strength', 'Flexibility']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),*/
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Search Exercises',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value; // Update search query
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _getFilteredExercises().length,
                itemBuilder: (context, index) {
                  final exercise = _getFilteredExercises()[index];
                  return ExerciseListItem(
                    exercise: {
                      ...exercise,
                      'programId': widget.programId,
                    },
                    onDelete: () =>
                        _showDeleteDialog('exercise', exercise['exerciseId']!),
                    onSelect: () {
                      final apiId = exercise['exerciseId'];
                      final exerciseId = exercise['id'];

                      context.go(
                          AppRoutes.exerciseDetails
                              .replaceAll(':apiId', apiId!)
                              .replaceAll(':exerciseId', exerciseId!),
                          extra: {
                            'exerciseId': apiId,
                            'programId': widget.programId,
                          });
                    },
                  );
                },
              ),
            ),
          ],
        ),
        ProgramActionButtons(
          programId: widget.programId,
          onDeleteProgram: () => _showDeleteDialog('program', widget.programId),
          onUpdateExercises: () async {
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
        ),
      ],
    );
  }
}
