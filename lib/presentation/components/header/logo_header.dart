import 'package:flutter/material.dart';
import 'package:grindstone/core/config/colors.dart';

class LogoHeader extends StatelessWidget {
  final bool isPurple;
  const LogoHeader({super.key, this.isPurple = false});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  isPurple
                      ? 'assets/logo/gPurple.png'
                      : 'assets/logo/gGreen.png',
                  height: 80,
                  width: 80,
                ),
                const SizedBox(height: 18),
                Center(
                  child: Text(
                    'Are you g?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: isPurple ? Colors.black : Colors.white),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(
                      child: Text(
                          isPurple
                              ? 'Fill out the following details'
                              : 'Login to access your',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: isPurple ? textLight : white,
                                  ),
                          textAlign: TextAlign.center),
                    )),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                      isPurple
                          ? 'to get started with your account!'
                          : 'programs and track progress',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isPurple ? textLight : white,
                          ),
                      textAlign: TextAlign.center),
                ),
              ],
            )));
  }
}
