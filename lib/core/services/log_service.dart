import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/model/log.dart';
import 'package:grindstone/core/services/user_provider.dart';
import 'package:grindstone/presentation/components/snackbar/toast.dart';
import 'package:uuid/uuid.dart';

class LogService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserProvider userProvider;

  LogService(this.userProvider);

  List<Log> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<QuerySnapshot>? _logSubscription;

  final Map<String, Log> _logCache = {};

  // getters
  List<Log> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  @override
  void dispose() {
    _cancelSubscriptions();
    super.dispose();
  }

  void _cancelSubscriptions() {
    _logSubscription?.cancel();
    _logSubscription = null;
  }

  bool _isAuthenticated() {
    // check current local state and firebase state
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && userProvider.isAuthenticated();
  }

  String? _getCurrentUserId() {
    if (!_isAuthenticated()) {
      _setError('USer not authenticated');
      return null;
    }

    final userId = userProvider.getUid();
    if (userId.isEmpty) {
      _setError('Cannot get current user ID');
      return null;
    }

    return userId;
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

  Future<T?> _executeWithErrorHandling<T>(

    Future<T?> Function() operation,
    String errorPrefix,
  ) async {
    if (!_isAuthenticated()) {
      _setError('User not authenticated');
      FailToast.show('User not authenticated');
      return null;
    }

    if (_getCurrentUserId() == null) {
      _setError('No user found');
      FailToast.show('No user found');
      return null;
    }

    _startLoading();

    try {
      // 1) Run the operation and capture the bool it returns:
      final success = await operation();

      // 2) Now check that bool:
      if (success is bool && success == false) {
        // The write returned false—treat as failure:
        print('🔥 createLog returned false');
        FailToast.show('Failed to save log (returned false)');
      } else {
        // Either it's true, or it's some other type—treat as success:
        print('✅ createLog succeeded: $success');
      }

      _endLoading();
      return success;
    } catch (e) {
      _endLoading();
      _setError('$errorPrefix: $e');
      FailToast.show('$errorPrefix');
      return null;
    }
  }

  // check if user trying to access is the owner of the log
  Future<bool> _hasAccessToLog(String logId) async {
    if (!_isAuthenticated()) return false;

    try {
      final doc = await _firestore.collection('logs').doc(logId).get();
      if (!doc.exists) return false;

      final data = doc.data();
      if (data == null) return false;

      // ito yung return if yes or no
      final userId = data['userId'];
      return userId == FirebaseAuth.instance.currentUser?.uid;
    } catch (e) {
      _setError('Failed to verify log access: $e');
      return false;
    }
  }

  void startLogListener() {
    final currentUserId = _getCurrentUserId();
    if (currentUserId == null) return;

    _cancelSubscriptions();
    _startLoading();

    try {
      _logSubscription = _firestore
          .collection('logs')
          .where('userId', isEqualTo: currentUserId)
          .snapshots()
          .listen((snapshot) {
        final logs =
            snapshot.docs.map((doc) => Log.fromMap(doc.data())).toList();

        _logs = logs;
        _endLoading();

        for (var log in logs) {
          _logCache[log.id] = log;
        }
      }, onError: (error) {
        _setError('Failed to fetch logs: $error');
        _endLoading();
        _cancelSubscriptions();
      }, onDone: () {
        _endLoading();
        _cancelSubscriptions();
      });
    } catch (e) {
      print('oraya error: $e');
      _setError('Failed to start log listener: $e');
      _endLoading();
      _cancelSubscriptions();
    }
  }

  // create a new log
  Future<bool> createLog(Log exerciseLog) async {
    return await _executeWithErrorHandling<bool>(
          () async {
            final userId = _getCurrentUserId();
            final docRef = _firestore.collection('logs').doc(exerciseLog.id);
            if (userId == null) {
              throw Exception('User ID is null. Cannot create log.');
            }
            await docRef.set({
              'id':exerciseLog.id,
              'userId': userId,
              'exerciseId': exerciseLog.id,
              if (exerciseLog.programId != null)
                'programId': exerciseLog.programId,
            },SetOptions(merge: true));


            final entry = exerciseLog.logs.last.toMap();
            await docRef.update({
              'logs': FieldValue.arrayUnion([entry]),
            });

            // update cache and realtime data
            _logCache[exerciseLog.id] = Log(
              id: exerciseLog.id,
              userId: userId,
              exerciseId: exerciseLog.exerciseId,
              programId: exerciseLog.programId,
             logs: [...?_logCache[exerciseLog.id]?.logs, entry].map((e) => DataLog.fromMap(e as Map<String, dynamic>)).toList(),
            );

            if (_logSubscription != null) {
              _logSubscription!.cancel();
            }

            return true;
          },
          'Failed to create log',
        ) ??
        false;
  }

  // fetch all logs based on userId and programId
  Future<List<Log>> fetchLogsByProgram({
    bool refresh = false,
    String? programId,
  }) async {
    final result = await _executeWithErrorHandling<List<Log>>(
      () async {
        final doc = await _firestore
            .collection('logs')
            .where('userId', isEqualTo: userProvider.userId)
            .where('programId', isEqualTo: programId)
            .get();

        final logs = doc.docs.map((doc) {
          final data = doc.data();
          if (data['logs'] == null) {
            data['logs'] = [];
          }
          return Log.fromMap(data);
        }).toList();

        // update cache and realtime data
        for (var log in logs) {
          _logCache[log.id] = log;
        }

        return logs;
      },
      'Failed to fetch logs',
    );

    return result ?? [];
  }

  Future<List<DataLog>> fetchLogById(String exerciseId) async {
    return await _executeWithErrorHandling<List<DataLog>>(
          () async {
            final doc = await _firestore
                .collection('logs')
                .where('exerciseId', isEqualTo: exerciseId)
                .get();

            if (doc.docs.isEmpty) return [];
            final data = doc.docs.first.data();
            if (data['logs'] == null) {
              data['logs'] = [];
            }

            final log = Log.fromMap(data);
            _logCache[log.id ?? ''] = log;

            print('Fetched log: ${log.toMap()}');
            return log.logs;
          },
          'Failed to fetch log',
        ) ??
        [];
  }

  // update log based on programId, userId and
  Future<bool> updateLog(
      {required String logId,
      required String programId,
      required String exerciseId,
      required DataLog newLog}) async {
    return await _executeWithErrorHandling<bool>(
          () async {
            if (!await _hasAccessToLog(logId)) return false;

            final logDoc = await _firestore.collection('logs').doc(logId).get();
            final logCollection = _firestore.collection('logs').doc(logId);

            if (logDoc.exists) {
              final data = logDoc.data();
              if (data != null && data['logs'] == null) {
                await logCollection.update({
                  'logs': [newLog.toMap()]
                });
              } else {
                await logCollection.update({
                  'logs': FieldValue.arrayUnion([newLog.toMap()])
                });
              }
            } else {
              return false;
            }

            if (_logSubscription == null) {
              await fetchLogsByProgram(refresh: true);
              await fetchLogById(exerciseId);
            } else {
              _logSubscription?.cancel();
              _logSubscription = null;
            }
            return true;
          },
          'Failed to update log',
        ) ??
        false;
  }

  // refresh all logs
  Future<void> refreshLogs() async {
    if (_logSubscription != null) {
      return;
    }

    await fetchLogsByProgram(refresh: true);
  }

  // refresh log based on programId
  Future<void> refreshLog(String programId) async {
    if (_logSubscription != null) {
      return;
    }

    await fetchLogsByProgram(programId: programId, refresh: true);
  }
}
