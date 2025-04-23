class Log {
  String date;
  int reps;
  int rir;
  String userId;
  int weight;

  Log({
    required this.date,
    required this.reps,
    required this.rir,
    required this.weight,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'reps': reps,
      'rir': rir,
      'weight': weight,
      'userId': userId,
    };
  }

  factory Log.fromMap(Map<String, dynamic> map) {
    return Log(
      date: map['date'],
      reps: map['reps'],
      rir: map['rir'],
      weight: map['weight'],
      userId: map['userId'],
    );
  }
}
