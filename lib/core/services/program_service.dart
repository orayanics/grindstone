import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'package:uuid/uuid.dart';

class ProgramService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider userProvider;
  final Map<String, String> _programsLastUpdated = {};

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

  String? _getCurrentUserId() {
    if (!_isAuthenticated()) {
      _setError('User not authenticated');
      return null;
    }

    final currentUserId = userProvider.getUid();
    if (currentUserId.isEmpty) {
      _setError('Cannot get current user ID');
      return null;
    }

    return currentUserId;
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _endLoading() {
    _isLoading = false;
    notifyListeners();
  }

  String? getLastUpdated(String programId) {
    return _programsLastUpdated[programId];
  }

  /// handle crud with try-catch
  Future<T?> _executeWithErrorHandling<T>(
    Future<T?> Function() operation,
    String errorPrefix,
  ) async {
    if (!_isAuthenticated()) {
      _setError('User not authenticated');
      return null;
    }

    _startLoading();

    try {
      final result = await operation();
      _endLoading();
      return result;
    } catch (e) {
      _setError('$errorPrefix: $e');
      return null;
    }
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
      _setError('Failed to verify program access: $e');
      return false;
    }
  }

  void startProgramsListener() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    _cancelSubscriptions();
    _startLoading();

    try {
      _programsSubscription = _firestore
          .collection('exercisePrograms')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen(
        (snapshot) {
          final programs = snapshot.docs
              .map((doc) => ExerciseProgram.fromMap(doc.data()))
              .toList();

          _programs = programs;
          _endLoading();

          for (var program in programs) {
            _programCache[program.id] = program;
          }
        },
        onError: (error) {
          _setError('Failed to listen for programs: $error');
          _endLoading();
          _cancelSubscriptions();
        },
        onDone: () {
          _endLoading();
          _cancelSubscriptions();
        },
      );
    } catch (e) {
      _setError('Failed to start programs listener: $e');
      _endLoading();
      _cancelSubscriptions();
    }
  }

  Future<void> updateLastUpdated(String programId, String newTimestamp) async {
    try {
      final programRef =
          _firestore.collection('exercisePrograms').doc(programId);

      await programRef.update({
        'lastUpdated': newTimestamp,
      });

      print('lastUpdated field updated successfully');
    } catch (e) {
      print('Failed to update lastUpdated field: $e');
    }
  }

  Future<bool> createProgram(ExerciseProgram program) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return false;

    return await _executeWithErrorHandling<bool>(
          () async {
            // add id to program.exercises
            final exercises = program.exercises.map((exercise) {
              return {
                ...exercise,
                'id': Uuid().v4(),
              };
            }).toList();

            program = ExerciseProgram(
              id: Uuid().v4(),
              userId: currentUserId,
              programName: program.programName,
              dayOfExecution: program.dayOfExecution,
              exercises: exercises,
            );

            await _firestore
                .collection('exercisePrograms')
                .doc(program.id)
                .set(program.toMap());

            _programCache[program.id] = program;

            if (_programsSubscription == null) {
              _programs.add(program);
            }

            return true;
          },
          'Failed to create program',
        ) ??
        false;
  }

  Future<void> fetchPrograms({
    DocumentSnapshot? lastDoc,
    int limit = 10,
    bool refresh = false,
  }) async {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    if (_programsSubscription != null && !refresh) {
      return;
    }

    await _executeWithErrorHandling<void>(
      () async {
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

        // Update cache
        for (var program in programs) {
          _programCache[program.id] = program;
        }
      },
      'Failed to fetch programs',
    );
  }

  Future<ExerciseProgram?> fetchProgramById(
    String programId, {
    bool refresh = false,
  }) async {
    if (!refresh && _programCache.containsKey(programId)) {
      return _programCache[programId];
    }

    return await _executeWithErrorHandling<ExerciseProgram?>(
      () async {
        final doc = await _firestore
            .collection('exercisePrograms')
            .doc(programId)
            .get();

        if (doc.exists) {
          final data = doc.data();

          final programUserId = data?['userId'] as String?;
          if (programUserId != userProvider.userId) {
            throw Exception('You do not have access to this program');
          }

          final program = ExerciseProgram.fromMap(data as Map<String, dynamic>);
          _programCache[programId] = program;

          final programIndex = _programs.indexWhere((p) => p.id == programId);
          if (programIndex != -1) {
            _programs[programIndex] = program;
          }

          return program;
        } else {
          throw Exception('Program not found');
        }
      },
      'Failed to fetch program',
    );
  }

  Future<bool> addExerciseToProgram(
    String programId,
    List<Map<String, dynamic>> exercises,
  ) async {
    if (!await _hasAccessToProgram(programId)) {
      _setError('You do not have access to this program');
      return false;
    }

    return await _executeWithErrorHandling<bool>(
          () async {
            await _firestore
                .collection('exercisePrograms')
                .doc(programId)
                .update({
              'exercises': FieldValue.arrayUnion(exercises
                  .map((exercise) => {
                        ...exercise,
                        'id': Uuid().v4(),
                      })
                  .toList()),
            });

            if (_programsSubscription == null) {
              await fetchProgramById(programId, refresh: true);
            }

            return true;
          },
          'Failed to add exercise',
        ) ??
        false;
  }

  Future<bool> deleteProgram(String programId) async {
    if (!await _hasAccessToProgram(programId)) {
      _setError('You do not have access to this program');
      return false;
    }

    return await _executeWithErrorHandling<bool>(
          () async {
            await _firestore
                .collection('exercisePrograms')
                .doc(programId)
                .delete();

            _programCache.remove(programId);

            if (_programsSubscription == null) {
              _programs.removeWhere((program) => program.id == programId);
            }

            return true;
          },
          'Failed to delete program',
        ) ??
        false;
  }

  Future<bool> deleteExercise(String programId, String exerciseId) async {
    if (!await _hasAccessToProgram(programId)) {
      _setError('You do not have access to this program');
      return false;
    }

    return await _executeWithErrorHandling<bool>(
          () async {
            final doc = await _firestore
                .collection('exercisePrograms')
                .doc(programId)
                .get();

            if (!doc.exists) {
              throw Exception('Program not found');
            }

            final data = doc.data();
            if (data == null || data['exercises'] == null) {
              throw Exception('No exercises found in the program');
            }

            final exercises =
                List<Map<String, dynamic>>.from(data['exercises']);
            final updatedExercises = exercises.where((exercise) {
              return exercise['exerciseId'] != exerciseId;
            }).toList();

            await _firestore
                .collection('exercisePrograms')
                .doc(programId)
                .update({
              'exercises': updatedExercises,
            });

            if (_programsSubscription == null) {
              await fetchProgramById(programId, refresh: true);
            }

            return true;
          },
          'Failed to delete exercise',
        ) ??
        false;
  }

  Future<void> refreshPrograms() async {
    if (_programsSubscription != null) {
      return;
    }

    await fetchPrograms(refresh: true);
  }

  Future<ExerciseProgram?> refreshProgram(String programId) async {
    return await fetchProgramById(programId, refresh: true);
  }
}
