import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:grindstone/core/config/theme.dart';
import 'package:grindstone/core/routes/app_router.dart';
import 'package:grindstone/core/config/firebase_options.dart';
import 'package:grindstone/core/services/user_session.dart';

import 'core/services/auth_service.dart';
import 'core/services/program_service.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  final _userProvider = UserProvider();
  late AuthService _authService;
  late ProgramService _programService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(_userProvider);
    _programService = ProgramService(_userProvider);
    _initServices();
  }

  @override
  void dispose() {
    _programService.dispose();
    super.dispose();
  }

  Future<void> _initServices() async {
    // auth and user listener
    _authService.initAuthListener();
    await _userProvider.initialize();

    if (_userProvider.isAuthenticated()) {
      _programService.startProgramsListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>.value(
          value: _authService,
        ),
        ChangeNotifierProvider<UserProvider>.value(
          value: _userProvider,
        ),
        ChangeNotifierProvider<ProgramService>.value(
          value: _programService,
        ),
      ],
      child: Builder(builder: (context) {
        final router = createRouter(context);

        return MaterialApp.router(
          routerConfig: router,
          debugShowCheckedModeBanner: false,
          theme: GrindstoneTheme.lightTheme,
        );
      }),
    );
  }
}
