import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  bool _initialized = false;
  bool _isLoading = true;

  // Getters
  String? get userId => _userId;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;

  //  user session from Firebase and Shared Preferences
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      // First check Firebase Auth current user
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        setUserId(firebaseUser.uid);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final savedUserId = prefs.getString('userId');

        if (savedUserId != null && savedUserId.isNotEmpty) {
          // if the saved user is still valid in Firebase
          try {
            await FirebaseAuth.instance.authStateChanges().first;
            if (FirebaseAuth.instance.currentUser != null) {
              setUserId(savedUserId);
            } else {
              await clearUserId();
            }
          } catch (e) {
            await clearUserId();
          }
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize user session: $e');
    } finally {
      _initialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setUserId(String userId) async {
    _userId = userId;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
    } catch (e) {
      debugPrint('Failed to save user ID: $e');
    }

    notifyListeners();
  }

  Future<void> clearUserId() async {
    _userId = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
    } catch (e) {
      debugPrint('Failed to clear user ID: $e');
    }

    notifyListeners();
  }

  String getUid() {
    String? firebaseUid = FirebaseAuth.instance.currentUser?.uid;

    if (firebaseUid != null && firebaseUid.isNotEmpty) {
      setUserId(firebaseUid);
      return firebaseUid;
    }

    return _userId ?? '';
  }

  bool isAuthenticated() {
    return _userId != null && _userId!.isNotEmpty;
  }
}
