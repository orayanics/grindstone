import 'package:grindstone/core/model/data_log.dart';

class Log {
  final String id;
  final String? userId;
  List<DataLog> logs;

  Log({required this.id, this.userId, required this.logs});

  Map<String, dynamic> toMap() {
    return {'id': id, 'userId': userId, 'logs': logs};
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'],
      userId: map['userId'],
      logs: List<DataLog>.from(map['logs'].map((log) => DataLog.fromMap(log))),
    );
  }
}
