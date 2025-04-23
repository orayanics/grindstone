class DataLog {
  final String? id;
  final String date;
  final String exerciseId;
  final int reps;
  final int rir;
  final int weight;

  DataLog({
    required this.id,
    required this.date,
    required this.exerciseId,
    required this.reps,
    required this.rir,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'exerciseId': exerciseId,
      'reps': reps,
      'rir': rir,
      'weight': weight,
    };
  }

  factory DataLog.fromMap(Map<String, dynamic> map) {
    return DataLog(
      id: map['id'],
      date: map['date'],
      exerciseId: map['exerciseId'],
      reps: map['reps'],
      rir: map['rir'],
      weight: map['weight'],
    );
  }
}
