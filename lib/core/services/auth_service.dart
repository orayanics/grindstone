import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:grindstone/core/routes/routes.dart';

class AuthService extends ChangeNotifier{

  bool get isSignedIn => FirebaseAuth.instance.currentUser != null;
  User? get currentUser => FirebaseAuth.instance.currentUser;

  Future<void> signup({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );

      await Future.delayed(const Duration(seconds:3));
      context.go(AppRoutes.profile);
    } on FirebaseAuthException catch(e) {
      String message = '';
      if(e.code == 'weak-password'){
        message = 'The password provided is too weak.';
      } else if(e.code == 'email-already-in-use'){
        message = 'The account already exists for that email.';
      }
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.SNACKBAR,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    catch (e) {
      Fluttertoast.showToast(
        msg: 'An unexpected error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> signin({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,


      );
      notifyListeners();
      Fluttertoast.showToast(
        msg: 'Login successful!',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      context.go(AppRoutes.profile);
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'invalid-email') {
        message = 'No user found with credentials.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      } else {
        message = 'Error: ${e.message}';
      }

      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    } catch (e) {

      Fluttertoast.showToast(
        msg: 'An unexpected error occurred. Please try again.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> signout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    notifyListeners();
    context.go(AppRoutes.home);
  }
}