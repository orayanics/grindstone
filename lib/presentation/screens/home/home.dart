import 'package:flutter/material.dart';
    import 'package:go_router/go_router.dart';
    import 'package:gym_tracker_flutter/routes/routes.dart';

    class HomeView extends StatelessWidget {
      const HomeView({super.key});

      @override
      Widget build(BuildContext context) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text('Register'),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('Login'),
                ),
              ],
            ),
          ),
        );
      }
    }