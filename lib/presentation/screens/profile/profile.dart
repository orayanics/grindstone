import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/routes/routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final authService = Provider.of<AuthService>(context, listen: false);
    final userId = authService.currentUser?.uid ?? '';

    return Scaffold(
<<<<<<< Updated upstream
      body: FloatingActionButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text('Go to Home')),
=======
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
>>>>>>> Stashed changes
    );
  }
              }