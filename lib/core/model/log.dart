import 'package:grindstone/core/model/data_log.dart';

class Log {
  final String id;
  final String? userId;
  final String? exerciseId;
  final String? programId;
  List<DataLog> logs;

  Log({
    required this.id,
    this.userId,
    required this.exerciseId,
    this.programId,
    required this.logs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'exerciseId': exerciseId,
      if (programId != null) 'programId': programId,
      'logs': logs.map((l) => l.toMap()).toList(),
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'],
      userId: map['userId'],
      exerciseId: map['exerciseId'],
      programId: map['programId'],
      logs: List<DataLog>.from(
        (map['logs'] as List).map((log) => DataLog.fromMap(log)),
      ),
    );
  }
}
