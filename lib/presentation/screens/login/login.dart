import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/exports/components.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: LoginTitle()),
      body: Padding(padding: const EdgeInsets.all(16.0), child: LoginForm()),
    );
  }
}

class LoginTitle extends StatelessWidget {
  const LoginTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'jump back in',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                wordSpacing: 2.0,
              ),
        ),
        Text(
          'welcome back!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                wordSpacing: 4.0,
              ),
        ),
      ],
    );
  }
}

class LoginForm extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        SizedBox(height: 16),
        PrimaryButton(
            label: 'Login',
            onPressed: () async {
              final authService =
                  Provider.of<AuthService>(context, listen: false);
              await authService.signin(
                email: _emailController.text,
                password: _passwordController.text,
                context: context,
              );
            })
      ],
    );
  }
}
