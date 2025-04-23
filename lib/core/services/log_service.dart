import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grindstone/core/exports/components.dart';
import 'package:grindstone/core/model/log.dart';

class LogService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> logExercise({
    required String programId,
    required String exerciseId,
    required int weight,
    required int reps,
    required int rir,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month}-${today.day}';

    final logData = {
      'userId': currentUser.uid,
      'weight': weight,
      'reps': reps,
      'rir': rir,
      'date': formattedDate,
    };

    final logRef = _firestore
        .collection("logs")
        .doc(currentUser.uid)
        .collection(programId)
        .doc(formattedDate)
        .collection("exercises")
        .doc(exerciseId);

    await logRef.set(logData, SetOptions(merge: true));
  }

  Future<Log?> returnLog({
    required String programId,
    required String exerciseId,
  }) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw Exception('User not logged in');
    }

    final today = DateTime.now();
    final formattedDate = '${today.year}-${today.month}-${today.day}';

    final logRef = _firestore
        .collection("logs")
        .doc(currentUser.uid)
        .collection(programId)
        .doc(formattedDate)
        .collection("exercises")
        .doc(exerciseId);

    final doc = await logRef.get();
    if (doc.exists) {
      return Log.fromMap(doc.data()!);
    } else {
      return null;
    }
  }
}
