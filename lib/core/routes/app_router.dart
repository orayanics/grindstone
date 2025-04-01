import 'package:go_router/go_router.dart';
import 'package:grindstone/exports/screens.dart';
import 'package:grindstone/exports/layouts.dart';

// Declare public routes here
final baseRoute = GoRoute(path: '/', builder: (context, state) => HomeView());

final registerRoute =
    GoRoute(path: '/register', builder: (context, state) => RegisterView());

// Declare private routes here
final profileRoute =
    GoRoute(path: '/profile', builder: (context, state) => ProfileView());

final createProgramRoute =
    GoRoute(path: '/create-program', builder: (context, state) => CreateProgramView(userId: '',));

// Private routes
final privateRoutes = ShellRoute(
    builder: (context, state, child) => PrivateLayout(child: child),
    routes: [
<<<<<<< Updated upstream
      GoRoute(path: '/profile', builder: (context, state) => ProfileView())
    ]);
=======
      profileRoute,createProgramRoute,
    ],
  redirect: (context,state) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final loggingIn = state.uri.toString() == '/login';
      if (!authService.isSignedIn && !loggingIn) {
        return '/login';
      }
      return null;
  }
);
>>>>>>> Stashed changes

final GoRouter appRouter = GoRouter(initialLocation: '/', routes: [
  baseRoute,
  registerRoute,
  privateRoutes,
  profileRoute,
]);

// Also declare your routes in routes.dart

//* TODO: Add Redirect Logic
//* TODO: Clean URL
