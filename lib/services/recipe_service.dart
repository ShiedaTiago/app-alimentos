import 'dart:convert';

import 'package:flutter/services.dart';

import '../core/utils/expiry.dart';
import '../core/utils/text_utils.dart';
import '../models/food_item.dart';
import '../models/recipe.dart';

/// Sugere receitas com base nos alimentos da casa (RF23).
class RecipeService {
  RecipeService(this._recipes);

  final List<Recipe> _recipes;

  /// Lê a base local `assets/recipes.json`.
  static Future<RecipeService> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString('assets/recipes.json');
    final list = jsonDecode(raw) as List;
    return RecipeService(
      list.map((e) => Recipe.fromMap(e as Map<String, dynamic>)).toList(),
    );
  }

  List<Recipe> get recipes => List.unmodifiable(_recipes);

  /// Ordena por (nº de ingredientes vencendo usados, nº de ingredientes que a
  /// casa tem). Alimentos consumidos, descartados ou já vencidos são ignorados.
  List<RecipeSuggestion> suggest(List<FoodItem> items, {DateTime? today}) {
    final usable = items.where((item) {
      return item.status == ItemStatus.active &&
          expiryStatusOf(item, today: today) != ExpiryStatus.expired;
    }).toList();

    final suggestions = <RecipeSuggestion>[];
    for (final recipe in _recipes) {
      final have = <RecipeIngredient>[];
      final missing = <RecipeIngredient>[];
      var expiring = 0;

      for (final ingredient in recipe.ingredients) {
        final matches = usable.where((i) => _matches(ingredient, i)).toList();
        if (matches.isEmpty) {
          if (!ingredient.optional) missing.add(ingredient);
          continue;
        }
        have.add(ingredient);
        if (matches.any((i) => _isExpiringSoon(i, today))) expiring++;
      }

      if (have.isEmpty) continue; // nada em comum com a casa
      suggestions.add(RecipeSuggestion(
        recipe: recipe,
        haveIngredients: have,
        missingIngredients: missing,
        expiringCount: expiring,
      ));
    }

    suggestions.sort(_compare);
    return suggestions;
  }

  // Nome do alimento (sem acento/maiúsculas) contém alguma palavra-chave.
  bool _matches(RecipeIngredient ingredient, FoodItem item) {
    final name = normalizeText(item.name);
    return ingredient.keywords.any((keyword) => name.contains(keyword));
  }

  bool _isExpiringSoon(FoodItem item, DateTime? today) {
    final status = expiryStatusOf(item, today: today);
    return status == ExpiryStatus.critical || status == ExpiryStatus.warning;
  }

  int _compare(RecipeSuggestion a, RecipeSuggestion b) {
    final byExpiring = b.expiringCount.compareTo(a.expiringCount);
    if (byExpiring != 0) return byExpiring;
    final byHave = b.haveIngredients.length.compareTo(a.haveIngredients.length);
    if (byHave != 0) return byHave;
    final byMissing =
        a.missingIngredients.length.compareTo(b.missingIngredients.length);
    if (byMissing != 0) return byMissing;
    return a.recipe.title.compareTo(b.recipe.title);
  }
}
