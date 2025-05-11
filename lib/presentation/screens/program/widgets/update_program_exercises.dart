import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:grindstone/presentation/screens/program/widgets/exercise_search_dialog.dart';

class UpdateProgramExercises extends StatefulWidget {
  const UpdateProgramExercises({
    super.key,
    required this.programId,
    required this.onUpdate,
  });

  final String programId;
  final Function onUpdate;

  @override
  State<UpdateProgramExercises> createState() {
    return _UpdateProgramExercisesState();
  }
}

class _UpdateProgramExercisesState extends State<UpdateProgramExercises> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openExerciseSearch();
    });
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

  Future<void> _openExerciseSearch() async {
    final selectedExercises = await ExerciseSearchDialog.show(context);
    if (selectedExercises != null) {
      await _addExercisesToProgram(selectedExercises);
    } else {
      GoRouter.of(context).pop();
    }
  }

  Future<void> _addExercisesToProgram(
      List<Map<String, dynamic>> selectedExercises) async {
    final programService = Provider.of<ProgramService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      FailToast.show('You must be logged in to update programs');
      Navigator.pop(context);
      return;
    }

    if (selectedExercises.isEmpty) {
      FailToast.show('Please select at least one exercise to add');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await programService.addExerciseToProgram(
          widget.programId, selectedExercises);

      if (!mounted) return;
      GoRouter.of(context).pop();

      setState(() {
        _isLoading = false;
      });

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

  @override

  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isLoading) const Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}

