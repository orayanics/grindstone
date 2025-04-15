import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:provider/provider.dart';

import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/presentation/components/header/logo_header.dart';
import 'package:grindstone/core/services/auth_service.dart';

// ignore lint issue here, it uses these packages for registration service

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  bool _isLoading = false;
  final GlobalKey<_RegisterFormState> _formKey =
      GlobalKey<_RegisterFormState>();

  void _updateLoadingState(bool isLoading) {
    setState(() {
      _isLoading = isLoading;
    });
  }

  void _handleBackPress(BuildContext context) {
    final formState = _formKey.currentState;
    if (formState != null && formState._currentStep > 0) {
      formState._previousStep();
    } else {
      GoRouter.of(context).go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: const Color.fromARGB(50, 0, 0, 0),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentPurple),
          onPressed: () => _handleBackPress(context),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LogoHeader(isPurple: true),
                        ],
                      ),
                    ),
                    RegisterForm(
                        key: _formKey, onLoadingChanged: _updateLoadingState),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class RegisterForm extends StatefulWidget {
  final Function(bool) onLoadingChanged;

  const RegisterForm({
    super.key,
    required this.onLoadingChanged,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  // Account info
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Personal info
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  // Health info
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  String _sex = 'Male';

  int _currentStep = 0;
  bool _isLoading = false;
  String? _passwordError;

  final List<String> _sexOptions = ['Male', 'Female', 'Other'];

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validatePasswordMatch() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _passwordError = 'Passwords do not match';
      });
      FailToast.show(_passwordError!);
      return false;
    }
    setState(() {
      _passwordError = null;
    });
    return true;
  }

  bool _validateCurrentStep() {
    bool isValid = _formKey.currentState?.validate() ?? false;

    if (_currentStep == 0) {
      isValid = isValid && _validatePasswordMatch();
    }

    return isValid;
  }

  void _nextStep() {
    if (_validateCurrentStep()) {
      setState(() {
        if (_currentStep < 2) {
          _currentStep++;
        }
      });
    }
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  Future<void> _completeRegistration() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });
    widget.onLoadingChanged(true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.signup(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        context: context,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.parse(_ageController.text),
        height: double.parse(_heightController.text),
        weight: double.parse(_weightController.text),
      );
    } catch (e) {
      FailToast.show("Something went wrong: ${e.toString()}");
    }

    setState(() {
      _isLoading = false;
    });
    widget.onLoadingChanged(false);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCurrentStepContent(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: AccentButton(
              onPressed: _currentStep < 2 ? _nextStep : _completeRegistration,
              label: _currentStep < 2 ? 'Next' : 'Register',
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == _currentStep ? accentPurple : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildAccountInfoStep();
      case 1:
        return _buildPersonalInfoStep();
      case 2:
        return _buildHealthInfoStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildAccountInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormInputEmail(
          controller: _emailController,
          label: 'Email Address',
          isRequired: true,
          isPrimary: false,
        ),
        const SizedBox(height: 16),
        FormInputPassword(
          controller: _passwordController,
          label: 'Password',
          isRequired: true,
          isPrimary: false,
        ),
        const SizedBox(height: 16),
        FormInputPassword(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          isRequired: true,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormInputText(
          controller: _firstNameController,
          label: 'First Name',
          isRequired: true,
          isPrimary: false,
        ),
        const SizedBox(height: 16),
        FormInputText(
          controller: _lastNameController,
          label: 'Last Name',
          isRequired: true,
          isPrimary: false,
        ),
      ],
    );
  }

  Widget _buildHealthInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormInputNumber(
          controller: _weightController,
          label: 'Weight (kg)',
          isRequired: true,
          isPrimary: false,
        ),
        const SizedBox(height: 16),
        FormInputNumber(
          controller: _heightController,
          label: 'Height (cm)',
          isRequired: true,
          isPrimary: false,
        ),
        const SizedBox(height: 16),
        CustomDropdown(
          label: 'Sex',
          options: _sexOptions,
          value: _sex,
          isRequired: true,
          onChanged: (String newValue) {
            setState(() {
              _sex = newValue;
            });
          },
        ),
        const SizedBox(height: 16),
        FormInputNumber(
          controller: _ageController,
          label: 'Age',
          isRequired: true,
          isPrimary: false,
        ),
      ],
    );
  }
}
