import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/screens.dart';
import 'package:grindstone/core/exports/layouts.dart';

// Declare public routes here
final baseRoute = GoRoute(path: '/', builder: (context, state) => HomeView());

final registerRoute =
    GoRoute(path: '/register', builder: (context, state) => RegisterView());

// Declare private routes here
final profileRoute =
    GoRoute(path: '/profile', builder: (context, state) => ProfileView());

// Private routes
final privateRoutes = ShellRoute(
    builder: (context, state, child) => PrivateLayout(child: child),
    routes: [
      GoRoute(path: '/profile', builder: (context, state) => ProfileView())
    ]);

final GoRouter appRouter = GoRouter(initialLocation: '/', routes: [
  baseRoute,
  registerRoute,
  privateRoutes,
  profileRoute,
]);

// Also declare your routes in routes.dart

//* TODO: Add Redirect Logic
//* TODO: Clean URL
