import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/user_session.dart';

class AuthService extends ChangeNotifier {
  bool get isSignedIn => FirebaseAuth.instance.currentUser != null;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final userProvider = context.read<UserProvider>();
    final navigator = GoRouter.of(context);

    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await Future.delayed(const Duration(seconds: 3));

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        userProvider.setUserId(userId);
        SuccessToast.show("Login Successful");
        navigator.go(AppRoutes.profile);
      }
    } on FirebaseAuthException catch (e) {
      FailToast.show(e.message.toString());
    } catch (e) {
      FailToast.show(e.toString());
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final userProvider = context.read<UserProvider>();
    final navigator = GoRouter.of(context);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId != null) {
        userProvider.setUserId(userId);
        notifyListeners();
        SuccessToast.show("Login Successful");
        navigator.go(AppRoutes.profile);
      }
    } on FirebaseAuthException catch (e) {
      FailToast.show(e.message.toString());
    } catch (e) {
      FailToast.show(e.toString());
    }
  }

  Future<void> signout(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final navigator = GoRouter.of(context);

    try {
      await FirebaseAuth.instance.signOut();

      userProvider.clearUserId();
      notifyListeners();
      SuccessToast.show("Logout Successful");
      navigator.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      FailToast.show(e.message.toString());
    } catch (e) {
      FailToast.show(e.toString());
    }
  }
}
