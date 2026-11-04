class RecipeIngredient {
  const RecipeIngredient({
    required this.name,
    required this.keywords,
    this.optional = false,
    this.excludes = const [],
  });

  final String name;
  final List<String> keywords; // sem acento e em minúsculas
  final bool optional;

  /// Expressões que descartam o alimento mesmo com a palavra-chave
  /// (ex.: "coco" para leite). Sem acento e em minúsculas.
  final List<String> excludes;

  factory RecipeIngredient.fromMap(Map<String, dynamic> map) {
    return RecipeIngredient(
      name: map['name'] as String,
      keywords: List<String>.from(map['keywords'] as List),
      optional: map['optional'] as bool? ?? false,
      excludes: List<String>.from(map['excludes'] as List? ?? const []),
    );
  }
}

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.minutes,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final int minutes;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      title: map['title'] as String,
      minutes: map['minutes'] as int,
      ingredients: (map['ingredients'] as List)
          .map((e) => RecipeIngredient.fromMap(e as Map<String, dynamic>))
          .toList(),
      steps: List<String>.from(map['steps'] as List),
    );
  }
}

/// Resultado da sugestão: o que a casa tem e o que falta para a receita.
class RecipeSuggestion {
  const RecipeSuggestion({
    required this.recipe,
    required this.haveIngredients,
    required this.missingIngredients,
    required this.expiringCount,
  });

  final Recipe recipe;
  final List<RecipeIngredient> haveIngredients;
  final List<RecipeIngredient> missingIngredients; // só os não opcionais
  final int expiringCount; // ingredientes que usam alimentos vencendo
}
