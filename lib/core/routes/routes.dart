class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';
  static const String createProgram = '/create-program';
  static const String programs = '/programs';
  static const String program = '/program-details/:programId';
}

// To call your routes:
// context.go(AppRoutes.home);
// context.push(AppRoutes.login);

// Go is replacing current screen
// Push is for adding a new screen on top of the current screen
