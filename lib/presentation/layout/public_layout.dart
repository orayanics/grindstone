import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';

class PublicLayout extends StatelessWidget {
  const PublicLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: PublicTitle(),
      ),
      body: child,
    );
  }
}

class PublicTitle extends StatelessWidget {
  const PublicTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go(AppRoutes.home);
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
