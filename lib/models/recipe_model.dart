class Recipe {
  final String name;
  final String category;
  final List<String> ingredients;
  final List<String> steps;
  final int time;
  final String difficulty;

  Recipe({
    required this.name,
    required this.category,
    required this.ingredients,
    required this.steps,
    required this.time,
    required this.difficulty,
  });
}