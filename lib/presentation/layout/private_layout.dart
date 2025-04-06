import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:flutter/material.dart';

class PrivateLayout extends StatelessWidget {
  const PrivateLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PrivateTitle(),
      ),
      body: child,
    );
  }
}

class PrivateTitle extends StatelessWidget {
  const PrivateTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.profile);
      },
      child: const Text(
        'grindstone',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
