import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grindstone/presentation/screens/program/widgets/search_exercises_list.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/exercise_api.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/services/auth_service.dart';

class CreateProgramView extends StatefulWidget {
  const CreateProgramView({super.key});

  @override
  State<CreateProgramView> createState() => _CreateProgramViewState();
}

class _CreateProgramViewState extends State<CreateProgramView> {
  // Input Controllers
  final _programName = TextEditingController();
  final _searchController = TextEditingController();

  // State variables
  final List<Map<String, String>> _selectedExercises = [];
  final List<String> _daysOfExecution = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? _selectedDayOfExecution;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _programName.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _checkAuthentication() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);

      if (!authService.isAuthenticated()) {
        FailToast.show('You must be logged in to create programs');
        context.go(AppRoutes.login);
      }
    });
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
    if (_selectedExercises.isEmpty) {
      FailToast.show('Please add at least one exercise to your program');
      return;
    }

    if (_selectedDayOfExecution == null || _selectedDayOfExecution!.isEmpty) {
      FailToast.show('Please select a day for your program');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);

    if (!authService.isAuthenticated()) {
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
      dayOfExecution: _selectedDayOfExecution!,
      exercises: _selectedExercises,
    );

    final programProvider = Provider.of<ProgramService>(context, listen: false);

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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Program name field
          FormInputText(
            controller: _programName,
            label: 'Program Name',
            isRequired: true,
            isPrimary: false,
          ),
          SizedBox(height: 16),
          // Day of execution dropdown
          CustomDropdown(
            label: 'Day of Execution',
            options: _daysOfExecution,
            value: _selectedDayOfExecution,
            isRequired: true,
            onChanged: (value) {
              setState(() {
                _selectedDayOfExecution = value;
              });
            },
          ),
          SizedBox(height: 16),
          // Search bar for exercises
          SearchExercisesList(),
          SizedBox(height: 8),

          _isSubmitting
              ? Center(child: CircularProgressIndicator())
              : PrimaryButton(
                  label: 'Create Program',
                  onPressed: _submitProgram,
                ),
        ],
      ),
    );
  }
}
