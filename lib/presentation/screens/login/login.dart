import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/auth_service.dart';

class RegisterView extends StatelessWidget {

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
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
              ElevatedButton(
                onPressed: () async {
                  final authService = Provider.of<AuthService>(context, listen: false);
                  await authService.signup(
                    email: _emailController.text,
                    password: _passwordController.text,
                    context: context,
                  );
                },

                child: const Text('Register'),
              )
            ],
          )
      ),
    );
  }
}