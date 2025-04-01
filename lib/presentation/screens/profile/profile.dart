import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/services/user_session.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {


    final userId = context.watch<UserProvider>().userId;
    final authService = context.read<AuthService>();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () async {
              await authService.signout(context);
              },
            child: Text('Logout'),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/create-program', extra: userId),
            child: Text('Create a Program'),
          ),
        ],
      ),
    );
  }
              }