import 'package:flutter/material.dart';

class PublicLayout extends StatelessWidget {
  const PublicLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Public Layout'),
      ),
      body: child,
    );
  }
}

