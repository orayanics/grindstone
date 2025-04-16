import 'package:flutter/material.dart';

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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF4755E6),
            Color(0xFF6164FB),
            Color(0xFF6164FB),
            Color(0xFF6165FB),
            Color(0xFF4755E6),
          ],
          stops: [0.0, 0.1, 0.5, 0.9, 1.0],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [const Text('Home')],
      ),
    );
  }
}
