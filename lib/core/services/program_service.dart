import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/user_session.dart';

class ProgramService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider userProvider;

  ProgramService(this.userProvider);

  // State variables
  List<ExerciseProgram> _programs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ExerciseProgram> get programs => _programs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // CREATE
  // Create a new exercise program
  Future<void> createProgram(ExerciseProgram program) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('exercisePrograms')
          .doc(program.id)
          .set(program.toMap());
      _programs.add(program);
    } catch (e) {
      _errorMessage = 'Failed to create program: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // READ
  // Fetch all exercise programs for a user with pagination
  Future<void> fetchPrograms(
      {DocumentSnapshot? lastDoc, int limit = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      Query query = _firestore
          .collection('exercisePrograms')
          .where('userId', isEqualTo: userProvider.userId)
          .limit(limit);
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
      final snapshot = await query.get();

      final exercises = snapshot.docs
          .map((doc) =>
              ExerciseProgram.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      _programs = exercises;
    } catch (e) {
      _errorMessage = 'Failed to fetch programs: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch a specific program by ID
  Future<ExerciseProgram?> fetchProgramById(String programId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final doc =
          await _firestore.collection('exercisePrograms').doc(programId).get();
      if (doc.exists) {
        final data = doc.data();
        final program = ExerciseProgram.fromMap(data as Map<String, dynamic>);
        return program;
      } else {
        _errorMessage = 'Program not found';
        return null;
      }
    } catch (e) {
      _errorMessage = 'Failed to fetch program: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // UPDATE
  // Add an exercise to an existing program
  Future<void> addExerciseToProgram(
      String programId, List<Map<String, dynamic>> exercises) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('exercisePrograms').doc(programId).update({
        'exercises': FieldValue.arrayUnion(exercises),
      });

      final program = _programs.firstWhere((p) => p.id == programId);
      program.exercises.addAll(exercises.map((exercise) {
        return {
          'exerciseId': exercise['exerciseId'],
          'name': exercise['name'],
        };
      }));
    } catch (e) {
      _errorMessage = 'Failed to add exercise: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // DELETE
  // Delete a program
  Future<void> deleteProgram(String programId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore.collection('exercisePrograms').doc(programId).delete();
      _programs.removeWhere((program) => program.id == programId);
    } catch (e) {
      _errorMessage = 'Failed to delete program: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete an exercise from a program
  Future<void> deleteExercise(String programId, String exerciseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final doc =
          await _firestore.collection('exercisePrograms').doc(programId).get();

      if (!doc.exists) {
        throw Exception('Program not found');
      }

      final data = doc.data();
      if (data == null || data['exercises'] == null) {
        throw Exception('No exercises found in the program');
      }

      final exercises = List<Map<String, dynamic>>.from(data['exercises']);
      final updatedExercises = exercises.where((exercise) {
        return exercise['exerciseId'] != exerciseId;
      }).toList();

      await _firestore.collection('exercisePrograms').doc(programId).update({
        'exercises': updatedExercises,
      });

      final program = _programs.firstWhere((p) => p.id == programId);
      program.exercises
          .removeWhere((exercise) => exercise['exerciseId'] == exerciseId);
    } catch (e) {
      _errorMessage = 'Failed to delete exercise: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
