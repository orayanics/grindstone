import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grindstone/core/model/exercise_program.dart';
import 'package:grindstone/core/services/user_session.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createExerciseProgram(ExerciseProgram program) async {
    try {
      await _db
          .collection('exercisePrograms')
          .doc(program.id)
          .set(program.toMap());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExerciseProgram>> fetchExercises(String userId) async {
    try {
      final snapshot = await _db
          .collection('exercisePrograms')
          .where('userId', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => ExerciseProgram.fromMap(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteExerciseProgram(String programId) async {
    try {
      await _db.collection('exercisePrograms').doc(programId).delete();
    } catch (e) {
      rethrow;
    }
  }
}

class ApiCalls {
  final FirestoreService _firestoreService = FirestoreService();
  final UserProvider userProvider;
  ApiCalls(this.userProvider);

  Future<List<ExerciseProgram>> fetchUserPrograms() async {
    String userId = userProvider.getUid();
    if (userId.isNotEmpty) {
      return _firestoreService.fetchExercises(userId);
    } else {
      return Future.value([]);
    }
  }
}
