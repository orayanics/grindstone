import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grindstone/core/model/exerciseProgram.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createExerciseProgram(ExerciseProgram program) async {
    try {
      await _db.collection('exercisePrograms').doc(program.id).set(program.toMap());
    } catch (e) {
      rethrow;
    }
  }
}