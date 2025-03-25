import 'package:flutter_dotenv/flutter_dotenv.dart';
    import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
    import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

    class DefaultFirebaseOptions {
      static FirebaseOptions get currentPlatform {
        if (kIsWeb) {
          return web;
        }
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return android;
          case TargetPlatform.iOS:
            return ios;
          case TargetPlatform.macOS:
            return macos;
          case TargetPlatform.windows:
            return windows;
          case TargetPlatform.linux:
            throw UnsupportedError(
              'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
            );
          default:
            throw UnsupportedError(
              'DefaultFirebaseOptions are not supported for this platform.',
            );
        }
      }

      static FirebaseOptions web = FirebaseOptions(
        apiKey: dotenv.env['WEB_WINDOWS_API_KEY'] ?? '',
        appId: dotenv.env['WEB_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        authDomain: dotenv.env['WEB_WINDOWS_AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );

      static FirebaseOptions android = FirebaseOptions(
        apiKey: dotenv.env['ANDROID_API_KEY'] ?? '',
        appId: dotenv.env['ANDROID_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );

      static FirebaseOptions ios = FirebaseOptions(
        apiKey: dotenv.env['IOS_API_KEY'] ?? '',
        appId: dotenv.env['IOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
        iosBundleId: dotenv.env['MAC_IOS_BUNDLE_ID'] ?? '',
      );

      static FirebaseOptions macos = FirebaseOptions(
        apiKey: dotenv.env['MACOS_API_KEY'] ?? '',
        appId: dotenv.env['MACOS_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
        iosBundleId: dotenv.env['MAC_IOS_BUNDLE_ID'] ?? '',
      );

      static FirebaseOptions windows = FirebaseOptions(
        apiKey: dotenv.env['WEB_WINDOWS_API_KEY'] ?? '',
        appId: dotenv.env['WEB_APP_ID'] ?? '',
        messagingSenderId: dotenv.env['MESSAGING_SENDER_ID'] ?? '',
        projectId: dotenv.env['PROJECT_ID'] ?? '',
        authDomain: dotenv.env['WEB_WINDOWS_AUTH_DOMAIN'] ?? '',
        storageBucket: dotenv.env['STORAGE_BUCKET'] ?? '',
      );
    }