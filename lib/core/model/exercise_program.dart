class ExerciseProgram {
  String id;
  String userId;
  String programName;
  String dayOfExecution;
  String? lastUpdated;
  List<Map<String, String>> exercises;

  ExerciseProgram({required this.id,
    required this.userId,
    required this.programName,
    required this.dayOfExecution,
    this.lastUpdated,
    required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'programName': programName,
      'dayOfExecution': dayOfExecution,
      'exercises': exercises,
      'lastUpdated': lastUpdated,
    };
  }

  factory ExerciseProgram.fromMap(Map<String, dynamic> map) {
    return ExerciseProgram(
      id: map['id'],
      userId: map['userId'],
      programName: map['programName'],
      dayOfExecution: map['dayOfExecution'],
      lastUpdated: map['lastUpdated'] as String? ?? '',
      // Provide a default value
      exercises: List<Map<String, String>>.from(
        (map['exercises'] as List).map(
              (exercise) => Map<String, String>.from(exercise),
        ),
      ),
    );
  }
}