// ... باقي الاستيرادات كما هي

class Exercise {
  final String name;
  final String description;
  final int rounds;
  final int reps;
  final String modelPath;

  final int difficulty;
  final String? muscleGroup;
  final List<String> instructions;
  final List<String> tips;

  Exercise({
    required this.name,
    required this.description,
    required this.rounds,
    required this.reps,
    required this.modelPath,
    this.difficulty = 3,
    this.muscleGroup,
    this.instructions = const [],
    this.tips = const [],
  });
}
