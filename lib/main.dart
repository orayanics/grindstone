import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
  import 'package:grindstone/core/routes/app_router.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:grindstone/core/config/firebase_options.dart';
import 'package:grindstone/core/services/user_session.dart';

import 'package:provider/provider.dart';

import 'core/services/auth_service.dart';

  void main() async {
    await dotenv.load(fileName: ".env");
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MainApp());
  }

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),

        ChangeNotifierProvider<UserProvider>(
          create: (_) => UserProvider(),
        ),

      ],
      child: MaterialApp.router(
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
