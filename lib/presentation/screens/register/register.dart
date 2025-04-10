import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/presentation/components/forms/stepper.dart';
import 'package:provider/provider.dart';

import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/presentation/components/header/logo_header.dart';
import 'package:grindstone/core/services/auth_service.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentPurple),
          onPressed: () {
            GoRouter.of(context).go('/');
          },
        ),
      ),
      body: Padding(
          padding: const EdgeInsets.all(36.0),
          child: Column(
            children: [
              LogoHeader(
                isPurple: true,
              ),
              RegisterForm()
            ],
          )),
    );
  }
}

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormInputEmail(
            isPrimary: false,
            controller: _emailController,
            label: 'Email Address',
            isRequired: true,
          ),
          const SizedBox(height: 12),
          FormInputPassword(
            isPrimary: false,
            controller: _passwordController,
            label: 'Password',
            isRequired: true,
          ),
          const SizedBox(height: 12),
          FormInputPassword(
            isPrimary: false,
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signup(
                email: _emailController.text,
                password: _passwordController.text,
                context: context,
              );
            },
            child: const Text('Register'),
          ),
          CustomStepper(
            currentStep: 0,
            steps: const [
              Step(
                title: Text('Step 1'),
                content: Text('Content for Step 1'),
              ),
              Step(
                title: Text('Step 2'),
                content: Text('Content for Step 2'),
              ),
            ],
            onStepContinue: () {},
            onStepCancel: () {},
          ),
        ],
      ),
    );
  }
}
