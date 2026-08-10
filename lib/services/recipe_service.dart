import '../models/recipe_model.dart';
import 'recipe_database.dart';

class RecipeMatch {
  final Recipe recipe;
  final double percentage;

  RecipeMatch({
    required this.recipe,
    required this.percentage,
  });
}

class RecipeService {
  static List<RecipeMatch> findRecipes(List<String> inventory) {

    List<String> items =
        inventory.map((e) => e.toLowerCase()).toList();

    List<RecipeMatch> matches = [];

    for (var recipe in recipeDatabase) {

      int matched = 0;

      for (var ingredient in recipe.ingredients) {
        if (items.contains(ingredient.toLowerCase())) {
          matched++;
        }
      }

      double percent =
          matched / recipe.ingredients.length * 100;

      if (percent > 30) {
        matches.add(
          RecipeMatch(
            recipe: recipe,
            percentage: percent,
          ),
        );
      }
    }

    matches.sort(
      (a, b) =>
          b.percentage.compareTo(a.percentage),
    );

    return matches;
  }
}