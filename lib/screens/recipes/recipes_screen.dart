import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../models/recipe.dart';
import '../../providers/recipe_provider.dart';
import '../../widgets/error_text.dart';

/// Receitas sugeridas com o que a casa tem (RF23).
class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

    final Widget body;
    if (provider.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (provider.loadError != null) {
      body = Center(child: ErrorText(provider.loadError));
    } else if (provider.suggestions.isEmpty) {
      body = const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma receita combina com seus alimentos.\n'
            'Cadastre mais itens para receber sugestões.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    } else {
      body = ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: provider.suggestions.length,
        itemBuilder: (_, index) =>
            _SuggestionCard(suggestion: provider.suggestions[index]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: body,
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({required this.suggestion});

  final RecipeSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final recipe = suggestion.recipe;
    final missing = suggestion.missingIngredients.length;
    return Card(
      child: ListTile(
        title: Text(recipe.title),
        subtitle: Text(
          'Tem ${suggestion.haveIngredients.length} · '
          '${missing == 0 ? 'Não falta nada' : 'Falta $missing'} · '
          '${recipe.minutes} min',
        ),
        trailing: suggestion.expiringCount > 0
            ? Tooltip(
                message: 'Usa alimentos vencendo',
                child: Icon(
                  Icons.schedule,
                  color: Theme.of(context).colorScheme.error,
                ),
              )
            : null,
        onTap: () => context.push('/recipes/${recipe.id}'),
      ),
    );
  }
}
