import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/config/colors.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/presentation/components/header/logo_header.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/exports/components.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(36.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LogoHeader(
            isPurple: false,
          ),
          const SizedBox(height: 16),
          LoginForm(),
          const SizedBox(height: 16),
          LoginRedirect()
        ],
      ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Address',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  wordSpacing: 2.0,
                )),
        const SizedBox(height: 6),
        FormInputEmail(
          isPrimary: true,
          controller: _emailController,
        ),
        const SizedBox(height: 12),
        Text('Password',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  wordSpacing: 2.0,
                )),
        const SizedBox(height: 6),
        FormInputPassword(
          isPrimary: true,
          controller: _passwordController,
        ),
        SizedBox(height: 16),
        const Divider(
          color: Colors.white,
          height: 1,
        ),
        SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: PrimaryButton(
              label: 'Login',
              onPressed: () async {
                final authService =
                    Provider.of<AuthService>(context, listen: false);
                await authService.signin(
                  email: _emailController.text,
                  password: _passwordController.text,
                  context: context,
                );
              }),
        )
      ],
    );
  }
}

class LoginRedirect extends StatelessWidget {
  const LoginRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Not yet a member? ",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
          ),
          TextButton(
            onPressed: () {
              GoRouter.of(context).go(AppRoutes.register);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
            ),
            child: const Text('Sign Up',
                style: TextStyle(
                  color: textAccent,
                )),
          ),
        ],
      ),
    );
  }
}
