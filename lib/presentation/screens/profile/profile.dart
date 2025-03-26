import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingActionButton(
          onPressed: () async {
            final authService = Provider.of<AuthService>(context, listen: false);
            await authService.signout(context);
          },
          child: Text('Logout')),
    );
  }
}
