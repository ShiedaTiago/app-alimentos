import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';

/// Detalhe da receita: ingredientes que a casa tem / faltam e o modo de preparo.
class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipeId});

  final String recipeId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();
    final suggestion = provider.suggestionById(recipeId);

    if (suggestion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Receita')),
        body: Center(
          child: provider.isLoading
              ? const CircularProgressIndicator()
              : const Text('Receita indisponível para seus alimentos.'),
        ),
      );
    }

    final recipe = suggestion.recipe;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Preparo: ${recipe.minutes} min', style: textTheme.bodyLarge),
          const SizedBox(height: 16),
          Text('Ingredientes', style: textTheme.titleMedium),
          _IngredientList(suggestion: suggestion),
          const SizedBox(height: 16),
          Text('Modo de preparo', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final (index, step) in recipe.steps.indexed)
            ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(step),
            ),
        ],
      ),
    );
  }
}

class _IngredientList extends StatelessWidget {
  const _IngredientList({required this.suggestion});

  final RecipeSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (final ingredient in suggestion.recipe.ingredients)
          ListTile(
            dense: true,
            leading: suggestion.haveIngredients.contains(ingredient)
                ? Icon(Icons.check_circle, color: colors.primary)
                : Icon(Icons.remove_circle_outline, color: colors.error),
            title: Text(ingredient.name),
            subtitle: Text(_statusOf(ingredient)),
          ),
      ],
    );
  }

  String _statusOf(RecipeIngredient ingredient) {
    if (suggestion.haveIngredients.contains(ingredient)) return 'Tem';
    return ingredient.optional ? 'Opcional' : 'Falta';
  }
}
