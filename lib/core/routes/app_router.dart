import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/screens.dart';
import 'package:grindstone/core/exports/layouts.dart';
import 'package:grindstone/core/services/auth_service.dart';
import 'package:provider/provider.dart';


// Declare public routes here
final baseRoute = GoRoute(path: '/', builder: (context, state) => HomeView());

final publicRoutes = ShellRoute(
    builder: (context, state, child) => PublicLayout(child: child),
  routes: [
    baseRoute,
    registerRoute,
    loginRoute,
  ],
  redirect: (context, state){
    final authService = Provider.of<AuthService>(context, listen: false);
    if (authService.isSignedIn) {
      return '/profile';
    }
    return null;
  }
);

final registerRoute =
    GoRoute(path: '/register', builder: (context, state) => RegisterView());

final loginRoute =
    GoRoute(path: '/login', builder: (context, state) => LoginView());

// Declare private routes here
final profileRoute =
    GoRoute(path: '/profile', builder: (context, state) => ProfileView());

// Private routes
final privateRoutes = ShellRoute(
    builder: (context, state, child) => PrivateLayout(child: child),
    routes: [
      profileRoute,
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

final GoRouter appRouter = GoRouter(
initialLocation: '/',
routes: [
publicRoutes,
privateRoutes,
],
);

// Also declare your routes in routes.dart

//* TODO: Add Redirect Logic
//* TODO: Clean URL
