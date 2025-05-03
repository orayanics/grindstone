class Exercise {
  final String id;
  final String name;
  final List<String> instructions;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> bodyParts;
  final List<String> equipments;

  Exercise(
      {
        required this.id,
      required this.name,
      required this.instructions,
      required this.targetMuscles,
      required this.secondaryMuscles,
      required this.bodyParts,
      required this.equipments});
}
