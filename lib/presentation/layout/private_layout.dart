import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

import 'package:grindstone/core/services/auth_service.dart';
import 'package:grindstone/core/services/user_session.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/config/colors.dart';

class PrivateLayout extends StatefulWidget {
  const PrivateLayout({super.key, required this.child});

  final Widget child;

  @override
  State<PrivateLayout> createState() => _PrivateLayoutState();
}

class _PrivateLayoutState extends State<PrivateLayout> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).matchedLocation;
    if (location.contains('/profile')) {
      setState(() => _selectedIndex = 2);
    } else if (location.contains('/programs') ||
        location.contains('/program-details') ||
        location.contains('/create-program')) {
      setState(() => _selectedIndex = 1);
    } else {
      setState(() => _selectedIndex = 0);
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // TODO: Add Dashboard/Home
        context.go(AppRoutes.profile);
        break;
      case 1:
        context.go(AppRoutes.programs);
        break;
      case 2:
        context.go(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);

    if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.login);
      });

      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: accentPurple),
          onPressed: () => GoRouter.of(context).go(AppRoutes.home),
        ),
        title: Center(
          child: Text(
            'grindstone',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: accentPurple,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: widget.child,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: white,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Programs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }
}
