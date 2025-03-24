import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_tracker_flutter/routes/routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingActionButton(
          onPressed: () => context.go(AppRoutes.home),
          child: Text('Go to Home')),
    );
  }
}
