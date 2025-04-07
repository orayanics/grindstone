class ExerciseProgram {
  String id;
  String userId;
  String programName;
  String dayOfExecution;
  List<Map<String, String>> exercises;

  ExerciseProgram(
      {required this.id,
      required this.userId,
      required this.programName,
      required this.dayOfExecution,
      required this.exercises});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'programName': programName,
      'dayOfExecution': dayOfExecution,
      'exercises': exercises
    };
  }

  factory ExerciseProgram.fromMap(Map<String, dynamic> map) {
    return ExerciseProgram(
      id: map['id'],
      userId: map['userId'],
      programName: map['programName'],
      dayOfExecution: map['dayOfExecution'],
      exercises: List<Map<String, String>>.from(
        (map['exercises'] as List).map(
          (exercise) => Map<String, String>.from(exercise),
        ),
      ),
    );
  }
}
