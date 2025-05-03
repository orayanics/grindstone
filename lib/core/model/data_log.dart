class DataLog {
  final String date;
  final int reps;
  final int rir;
  final int weight;
  final String action;

  DataLog({
    required this.date,
    required this.reps,
    required this.rir,
    required this.weight,
    required this.action,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'reps': reps,
      'rir': rir,
      'weight': weight,
      'action': action,
    };
  }

  factory DataLog.fromMap(Map<String, dynamic> map) {
    return DataLog(
      date: map['date'],
      reps: map['reps'],
      rir: map['rir'],
      weight: map['weight'],
      action: map['action'],
    );
  }
}
