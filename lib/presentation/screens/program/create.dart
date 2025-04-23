import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grindstone/presentation/screens/program/widgets/search_exercises_list.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/program_service.dart';
import 'package:grindstone/core/routes/routes.dart';
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
  final _formKey = GlobalKey<FormState>();

  // State variables
  List<Map<String, dynamic>> _selectedExercises = [];
  final List<String> _daysOfExecution = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  String? _selectedDayOfExecution = 'Monday';
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

  void _handleExercisesSelected(List<Map<String, dynamic>> exercises) {
    setState(() {
      _selectedExercises = exercises;
    });
  }

  Future<void> _submitProgram() async {
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

    bool isValid = _formKey.currentState!.validate();

    if (_selectedExercises.isEmpty) {
      isValid = false;
      FailToast.show('Please add at least one exercise to your program');
      return;
    }

    try {
      if (isValid) {
        setState(() {
          _isSubmitting = true;
        });
        final program = ExerciseProgram(
          id: Uuid().v4(),
          userId: currentUser.uid,
          programName: _programName.text.trim(),
          dayOfExecution: _selectedDayOfExecution!.trim(),
          exercises: _selectedExercises
              .map((e) => Map<String, String>.from(e))
              .toList(),
        );

        final programProvider =
            Provider.of<ProgramService>(context, listen: false);

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
    return Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Program name field
              FormInputText(
                controller: _programName,
                label: 'Program Name',
                placeholder: 'Program Name',
                isRequired: true,
                isPrimary: false,
                isAlphanumeric: true,
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
              SearchExercisesList(
                initialExercises: _selectedExercises,
                onExercisesSelected: _handleExercisesSelected,
              ),
              SizedBox(height: 8),

              _isSubmitting
                  ? Center(child: CircularProgressIndicator())
                  : PrimaryButton(
                      label: 'Create Program',
                      onPressed: _submitProgram,
                    ),
            ],
          ),
        ));
  }
}
