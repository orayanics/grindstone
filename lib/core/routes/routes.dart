class AppRoutes {
  static const String login = '/';
  static const String home = '/home';
  static const String register = '/register';

  static const String profile = '/profile';
  static const String updatePersonal = '$profile/personal';
  static const String updateHealth = '$profile/health';
  static const String changePassword = '$profile/password';

  static const String createProgram = '/create-program';
  static const String programs = '/programs';
  static const String program = '/program-details/:programId';
  static const String exerciseDetails = '/exercise/:exerciseId/:logId';
}

// To call your routes:
// context.go(AppRoutes.home);
// context.push(AppRoutes.login);

// Go is replacing current screen
// Push is for adding a new screen on top of the current screen
