import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
  import 'package:gym_tracker_flutter/routes/app_router.dart';
  import 'package:firebase_core/firebase_core.dart';
  import 'package:provider/provider.dart';
  import 'package:gym_tracker_flutter/services/auth_service.dart';
  import 'firebase_options.dart';

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
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
