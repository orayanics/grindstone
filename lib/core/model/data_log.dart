class DataLog {
  final String date;
  final int reps;
  final int rir;
  final int weight;

  DataLog({
    required this.date,
    required this.reps,
    required this.rir,
    required this.weight,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'reps': reps,
      'rir': rir,
      'weight': weight,
    };
  }

  factory DataLog.fromMap(Map<String, dynamic> map) {
    return DataLog(
      date: map['date'],
      reps: map['reps'],
      rir: map['rir'],
      weight: map['weight'],
    );
  }
}
