import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProvider with ChangeNotifier {
  String? _userId;
  String? _firstName;
  String? _lastName;
  int? _age;
  double? _height;
  double? _weight;

  bool _initialized = false;
  bool _isLoading = true;

  // Getters
  String? get userId => _userId;
  String? get firstName => _firstName;
  String? get lastName => _lastName;
  int? get age => _age;
  double? get height => _height;
  double? get weight => _weight;
  bool get isInitialized => _initialized;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;

      if (firebaseUser != null) {
        await setUserId(firebaseUser.uid);
        await _fetchUserProfileData(firebaseUser.uid);
      } else {
        final prefs = await SharedPreferences.getInstance();
        final savedUserId = prefs.getString('userId');

        if (savedUserId != null && savedUserId.isNotEmpty) {
          try {
            await FirebaseAuth.instance.authStateChanges().first;
            if (FirebaseAuth.instance.currentUser != null) {
              await setUserId(savedUserId);
              // Fetch user profile data from Firestore
              await _fetchUserProfileData(savedUserId);
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

  Future<void> _fetchUserProfileData(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        await setUserProfile(
          firstName: userData?['firstName'] ?? 'No fetch',
          lastName: userData?['lastName'] ?? 'No fetch',
          age: userData?['age'] ?? 0,
          height: userData?['height'] ?? 0.0,
          weight: userData?['weight'] ?? 0.0,
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch user profile data: $e');
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

  Future<void> setUserProfile({
    required String firstName,
    required String lastName,
    required int age,
    required double height,
    required double weight,
  }) async {
    _firstName = firstName;
    _lastName = lastName;
    _age = age;
    _height = height;
    _weight = weight;
    notifyListeners();
  }
}
