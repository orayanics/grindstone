import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/routes/routes.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: ButtonContainer());
  }
}

class ButtonContainer extends StatelessWidget {
  const ButtonContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: [
          PrimaryButton(
              label: 'Login',
              onPressed: () {
                context.go(AppRoutes.login);
              }),
          AccentButton(
              label: 'Register',
              onPressed: () {
                context.go(AppRoutes.register);
              })
        ],
      ),
    );
  }
}
