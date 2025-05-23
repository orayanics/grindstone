import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/screens.dart';
import 'package:grindstone/core/exports/layouts.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// router with context and providers
GoRouter createRouter(BuildContext context) {
  final authService = Provider.of<AuthService>(context, listen: false);

  // Public routes
  final registerRoute =
      GoRoute(path: '/register', builder: (context, state) => RegisterView());

  final loginRoute =
      GoRoute(path: '/', builder: (context, state) => LoginView());

  // Private routes
  final homeRoute =
      GoRoute(path: '/home', builder: (context, state) => HomeView());

  final profileRoute =
      GoRoute(path: '/profile', builder: (context, state) => ProfileView());

  final createProgramRoute = GoRoute(
      path: '/create-program',
      builder: (context, state) {
        return CreateProgramView();
      });

  final indexProgramRoute = GoRoute(
      path: '/programs', builder: (context, state) => ProgramIndexView());

  final programDetailsRoute = GoRoute(
    path: '/program-details/:programId',
    builder: (context, state) {
      final programId = state.pathParameters['programId'];
      final programName = state.extra as String;
      return ProgramDetailsView(
          programId: programId!, programName: programName);
    },
  );

  final profileHealth = GoRoute(
      path: AppRoutes.updateHealth,
      builder: (context, state) => ProfileHealthView());

  final profilePersonal = GoRoute(
      path: AppRoutes.updatePersonal,
      builder: (context, state) => ProfilePersonalView());

  final profilePassword = GoRoute(
      path: AppRoutes.changePassword,
      builder: (context, state) => ProfilePasswordView());

  final exerciseDetails = GoRoute(
      path: AppRoutes.exerciseDetails,
      builder: (context, state) {
        final apiId = state.pathParameters['apiId'];
        final exerciseId = state.pathParameters['exerciseId'];
        final extra = state.extra as Map<String, dynamic>?; // Cast extra to Map
        final programId = extra?['programId'] ?? ''; // Extract programId
        return ExerciseDetailsView(apiId: apiId!, exerciseId: exerciseId!, programId: programId!);
      });

  // Public shell route
  final publicRoutes = ShellRoute(
      builder: (context, state, child) => PublicLayout(child: child),
      routes: [
        registerRoute,
        loginRoute,
      ],
      redirect: (context, state) {
        if (authService.isAuthenticated() && (state.matchedLocation == '/' || state.matchedLocation == '/register')) {
          // Redirect authenticated users only if they are on login or register
          return '/home';
        }
        return null;
      });

  // Private shell route
  final privateRoutes = ShellRoute(
      builder: (context, state, child) => PrivateLayout(child: child),
      routes: [
        homeRoute,
        profileRoute,
        createProgramRoute,
        indexProgramRoute,
        programDetailsRoute,
        profileHealth,
        profilePersonal,
        profilePassword,
        exerciseDetails,
      ],
      redirect: (context, state) {
        if (!authService.isAuthenticated()) {
          // Redirect unauthenticated users to login
          return '/';
        }
        return null;
      });

  // create instance and return the router
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authService,
    routes: [
      publicRoutes,
      privateRoutes,
    ],
    redirect: (context, state) {
      final isAuthenticated = authService.isAuthenticated();
      final isLoggingIn = state.matchedLocation == '/';
      final isRegistering = state.matchedLocation == '/register';

      // Redirect unauthenticated users to login
      if (!isAuthenticated && !isLoggingIn && !isRegistering) {
        return '/';
      }

      // Prevent authenticated users from accessing login or register
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/home'; // Redirect to home or another default private route
      }

      // No redirection needed
      return null;
    },
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
  );
}