import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingActionButton(
          onPressed: // go to profile
              () => context.go(AppRoutes.profile),
          child: const Text('Go to Profile')),
    );
  }
}
