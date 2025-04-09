import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:provider/provider.dart';
import 'package:grindstone/core/routes/routes.dart';
import 'package:grindstone/core/services/user_session.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isSignedIn => _auth.currentUser != null;
  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void initAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    final userProvider = context.read<UserProvider>();
    final navigator = GoRouter.of(context);

    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user != null) {
        await userProvider.setUserId(user.uid);
        notifyListeners();
        SuccessToast.show("Registration Successful");
        navigator.go(AppRoutes.profile);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Registration failed";
      if (e.code == 'weak-password') {
        errorMessage = "The password provided is too weak";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "The account already exists for that email";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      }
      FailToast.show(errorMessage);
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
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await userProvider.setUserId(user.uid);
        notifyListeners();
        SuccessToast.show("Login Successful");
        navigator.go(AppRoutes.profile);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Login failed";
      if (e.code == 'user-not-found') {
        errorMessage = "No user found for that email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong password provided";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email address";
      } else if (e.code == 'user-disabled') {
        errorMessage = "User account has been disabled";
      }
      FailToast.show(errorMessage);
    } catch (e) {
      FailToast.show(e.toString());
    }
  }

  Future<void> signout(BuildContext context) async {
    final userProvider = context.read<UserProvider>();
    final navigator = GoRouter.of(context);

    try {
      await _auth.signOut();
      await userProvider.clearUserId();
      notifyListeners();
      SuccessToast.show("Logout Successful");
      navigator.go(AppRoutes.home);
    } on FirebaseAuthException catch (e) {
      FailToast.show(e.message.toString());
    } catch (e) {
      FailToast.show(e.toString());
    }
  }

  bool isAuthenticated(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return isSignedIn && userProvider.isAuthenticated();
  }
}
