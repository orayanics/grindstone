import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/user_session.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ProgramService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider userProvider;

  ProgramService(this.userProvider);

  List<ExerciseProgram> _programs = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _programsSubscription;

  final Map<String, ExerciseProgram> _programCache = {};

  // Getters
  List<ExerciseProgram> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _programsSubscription?.cancel();
    _programsSubscription = null;
  }

  bool _isAuthenticated() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && userProvider.isAuthenticated();
  }

  Future<bool> _hasAccessToProgram(String programId) async {
    if (!_isAuthenticated()) return false;

    try {
      final doc =
          await _firestore.collection('exercisePrograms').doc(programId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      return data['userId'] == userProvider.userId;
    } catch (e) {
      _errorMessage = 'Failed to verify program access: $e';
      return false;
    }
  }

  void startProgramsListener() {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    final currentUserId = userProvider.getUid();
    if (currentUserId.isEmpty) {
      _errorMessage = 'Cannot get current user ID';
      notifyListeners();
      return;
    }

    _cancelSubscriptions();

    _isLoading = true;
    notifyListeners();

    try {
      _programsSubscription = _firestore
          .collection('exercisePrograms')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen((snapshot) {
        final programs = snapshot.docs
            .map((doc) => ExerciseProgram.fromMap(doc.data()))
            .toList();

        _programs = programs;
        _isLoading = false;
        _errorMessage = null;

        for (var program in programs) {
          _programCache[program.id] = program;
        }

        notifyListeners();
      }, onError: (error) {
        _errorMessage = 'Failed to listen for programs: $error';
        _isLoading = false;
        notifyListeners();
      });
    } catch (e) {
      _errorMessage = 'Failed to start programs listener: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // CREATE
  // Create a new exercise program
  Future<bool> createProgram(ExerciseProgram program) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = userProvider.getUid();
      if (currentUserId.isEmpty) {
        _errorMessage = 'Cannot get current user ID';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      program = ExerciseProgram(
        id: program.id,
        userId: currentUserId,
        programName: program.programName,
        dayOfExecution: program.dayOfExecution,
        exercises: program.exercises,
      );

      await _firestore
          .collection('exercisePrograms')
          .doc(program.id)
          .set(program.toMap());

      _programCache[program.id] = program;

      if (_programsSubscription == null) {
        _programs.add(program);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create program: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // READ
  // Fetch all exercise programs for a user with pagination
  Future<void> fetchPrograms(
      {DocumentSnapshot? lastDoc, int limit = 10, bool refresh = false}) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    if (_programsSubscription != null && !refresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentUserId = userProvider.getUid();
      if (currentUserId.isEmpty) {
        _errorMessage = 'Cannot get current user ID';
        _isLoading = false;
        notifyListeners();
        return;
      }

      Query query = _firestore
          .collection('exercisePrograms')
          .where('userId', isEqualTo: currentUserId)
          .limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();

      final programs = snapshot.docs
          .map((doc) =>
              ExerciseProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _programs = programs;

      for (var program in programs) {
        _programCache[program.id] = program;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch programs: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a specific program by ID
  Future<ExerciseProgram?> fetchProgramById(String programId,
      {bool refresh = false}) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return null;
    }

    // no force refresh and have the program in cache, return
    if (!refresh && _programCache.containsKey(programId)) {
      return _programCache[programId];
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc =
          await _firestore.collection('exercisePrograms').doc(programId).get();
      if (doc.exists) {
        final data = doc.data();

        final programUserId = data?['userId'] as String?;
        if (programUserId != userProvider.userId) {
          _errorMessage = 'You do not have access to this program';
          _isLoading = false;
          notifyListeners();
          return null;
        }

        final program = ExerciseProgram.fromMap(data as Map<String, dynamic>);

        _programCache[programId] = program;

        final programIndex = _programs.indexWhere((p) => p.id == programId);
        if (programIndex != -1) {
          _programs[programIndex] = program;
        }

        _isLoading = false;
        notifyListeners();
        return program;
      } else {
        _errorMessage = 'Program not found';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch program: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  // UPDATE
  // Add an exercise to an existing program
  Future<bool> addExerciseToProgram(
      String programId, List<Map<String, dynamic>> exercises) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    if (!await _hasAccessToProgram(programId)) {
      _errorMessage = 'You do not have access to this program';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('exercisePrograms').doc(programId).update({
        'exercises': FieldValue.arrayUnion(exercises),
      });

      if (_programsSubscription == null) {
        await fetchProgramById(programId, refresh: true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add exercise: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // DELETE
  // Delete a program
  Future<bool> deleteProgram(String programId) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    if (!await _hasAccessToProgram(programId)) {
      _errorMessage = 'You do not have access to this program';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('exercisePrograms').doc(programId).delete();

      _programCache.remove(programId);

      if (_programsSubscription == null) {
        _programs.removeWhere((program) => program.id == programId);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete program: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Delete an exercise from a program
  Future<bool> deleteExercise(String programId, String exerciseId) async {
    if (!_isAuthenticated()) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return false;
    }

    if (!await _hasAccessToProgram(programId)) {
      _errorMessage = 'You do not have access to this program';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc =
          await _firestore.collection('exercisePrograms').doc(programId).get();

      if (!doc.exists) {
        _errorMessage = 'Program not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final data = doc.data();
      if (data == null || data['exercises'] == null) {
        _errorMessage = 'No exercises found in the program';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final exercises = List<Map<String, dynamic>>.from(data['exercises']);
      final updatedExercises = exercises.where((exercise) {
        return exercise['exerciseId'] != exerciseId;
      }).toList();

      await _firestore.collection('exercisePrograms').doc(programId).update({
        'exercises': updatedExercises,
      });

      if (_programsSubscription == null) {
        await fetchProgramById(programId, refresh: true);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete exercise: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Force refresh all programs
  Future<void> refreshPrograms() async {
    if (_programsSubscription != null) {
      return;
    }

    await fetchPrograms(refresh: true);
  }

  // Force refresh a specific program
  Future<ExerciseProgram?> refreshProgram(String programId) async {
    return await fetchProgramById(programId, refresh: true);
  }
}
