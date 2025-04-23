import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grindstone/core/model/data_log.dart';
import 'package:grindstone/core/model/log.dart';
import 'package:grindstone/core/services/user_provider.dart';
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
      return null;
    }

    if (_getCurrentUserId() == null) {
      _setError('No user found');
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
          _logCache[log.id ?? ''] = log;
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
            final logId = Uuid().v4();

            exerciseLog = Log(
              id: logId,
              programId: exerciseLog.programId,
              userId: userProvider.userId ?? '',
              logs: exerciseLog.logs ?? [],
            );

            await _firestore
                .collection('logs')
                .doc(logId)
                .set(exerciseLog.toMap());

            // update cache and realtime data
            _logCache[logId] = exerciseLog;

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
    DocumentSnapshot? lastDoc,
    int limit = 10,
    bool refresh = false,
    String? programId,
  }) async {
    if (_logSubscription != null && !refresh) {
      return _logs;
    }

    await _executeWithErrorHandling<List<Log>>(
      () async {
        Query query = _firestore
            .collection('logs')
            .where('userId', isEqualTo: userProvider.userId)
            .where('programId', isEqualTo: programId)
            .limit(limit);

        if (lastDoc != null) {
          query = query.startAfterDocument(lastDoc);
        }

        final snapshot = await query.get();

        final logs = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure logs field is never null
          if (data['logs'] == null) {
            data['logs'] = [];
          }
          return Log.fromMap(data);
        }).toList();

        _logs = logs;

        for (var log in logs) {
          _logCache[log.id ?? ''] = log;
        }

        return logs;
      },
      'Failed to fetch logs',
    );
  }

  // fetch log based on logId
  Future<Log?> fetchLogById(String logId) async {
    return await _executeWithErrorHandling<Log?>(
      () async {
        final doc = await _firestore.collection('logs').doc(logId).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          // Ensure logs field is never null
          if (data['logs'] == null) {
            data['logs'] = [];
          }
          print('oraya log found');
          return Log.fromMap(data);
        }
        return null;
      },
      'Failed to fetch log',
    );
  }

  // update log based on programId, userId and
  Future<bool> updateLog(
      {required String logId, required DataLog newLog}) async {
    return await _executeWithErrorHandling<bool>(
          () async {
            if (!await _hasAccessToLog(logId)) return false;

            final logDoc = await _firestore.collection('logs').doc(logId).get();
            final logCollection = _firestore.collection('logs').doc(logId);

            if (logDoc.exists) {
              final data = logDoc.data() as Map<String, dynamic>?;
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
              await fetchLogById(logId);
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
