import 'package:grindstone/core/model/data_log.dart';

class Log {
  String? id;
  String programId;
  String? userId;
  List<DataLog> logs;

  Log({this.id, required this.programId, this.userId, required this.logs});

  Map<String, dynamic> toMap() {
    return {'id': id, 'programId': programId, 'userId': userId, 'logs': logs};
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      id: map['id'],
      programId: map['programId'],
      userId: map['userId'],
      logs: List<DataLog>.from(map['logs'].map((log) => DataLog.fromMap(log))),
    );
  }
}
