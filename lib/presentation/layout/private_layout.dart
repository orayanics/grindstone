import 'package:flutter/material.dart';

class PrivateLayout extends StatelessWidget {
  const PrivateLayout({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Private Layout'),
      ),
      body: child,
    );
  }
}
