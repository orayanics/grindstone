import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/screens.dart';
import 'package:grindstone/core/exports/layouts.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:grindstone/core/services/user_session.dart';

// router with context and providers
GoRouter createRouter(BuildContext context) {
  final authService = Provider.of<AuthService>(context, listen: false);
  final userProvider = Provider.of<UserProvider>(context, listen: false);

  // Public routes
  final baseRoute = GoRoute(path: '/', builder: (context, state) => HomeView());

  final registerRoute =
      GoRoute(path: '/register', builder: (context, state) => RegisterView());

  final loginRoute =
      GoRoute(path: '/', builder: (context, state) => LoginView());

  // Private routes
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

  // Public shell route
  final publicRoutes = ShellRoute(
      builder: (context, state, child) => PublicLayout(child: child),
      routes: [
        baseRoute,
        registerRoute,
        loginRoute,
      ],
      redirect: (context, state) {
        if (authService.isSignedIn && userProvider.isAuthenticated()) {
          return '/profile';
        }
        return null;
      });

  // Private shell route
  final privateRoutes = ShellRoute(
      builder: (context, state, child) => PrivateLayout(child: child),
      routes: [
        profileRoute,
        createProgramRoute,
        indexProgramRoute,
        programDetailsRoute,
        profileHealth,
        profilePersonal,
        profilePassword
      ],
      redirect: (context, state) {
        if (!authService.isSignedIn || !userProvider.isAuthenticated()) {
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
      final isAuthenticated =
          authService.isSignedIn && userProvider.isAuthenticated();
      final isLoggingIn = state.matchedLocation == '/';
      final isRegistering = state.matchedLocation == '/register';
      final isPublicRoute = state.matchedLocation == '/';

      // if no no auth and try to access priv
      if (!isAuthenticated &&
          !isLoggingIn &&
          !isRegistering &&
          !isPublicRoute) {
        return '/';
      }

      // if ok
      if (isAuthenticated && (isLoggingIn || isRegistering)) {
        return '/profile';
      }

      return null;
    },
    errorBuilder: (context, state) => const Scaffold(
      body: Center(
        child: Text('Page not found'),
      ),
    ),
  );
}

// Also declare your routes in routes.dart

//* TODO: Add Redirect Logic
//* TODO: Clean URL
