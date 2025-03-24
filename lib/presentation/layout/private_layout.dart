import 'package:flutter/material.dart';

class PrivateLayout extends StatelessWidget {
  const PrivateLayout({Key? key, required this.child}) : super(key: key);

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
