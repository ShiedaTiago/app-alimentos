import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/recipe.dart';

// Garante que o assets/recipes.json está bem formado e completo.
void main() {
  final raw = File('assets/recipes.json').readAsStringSync();
  final recipes = (jsonDecode(raw) as List)
      .map((e) => Recipe.fromMap(e as Map<String, dynamic>))
      .toList();

  test('tem cerca de 20 receitas com ids únicos', () {
    expect(recipes.length, greaterThanOrEqualTo(20));
    expect(recipes.map((r) => r.id).toSet().length, recipes.length);
  });

  test('toda receita tem ingredientes obrigatórios e passos', () {
    for (final recipe in recipes) {
      expect(recipe.steps, isNotEmpty, reason: recipe.id);
      expect(
        recipe.ingredients.any((i) => !i.optional),
        isTrue,
        reason: recipe.id,
      );
    }
  });

  test('palavras-chave estão em minúsculas e sem acento', () {
    final plain = RegExp(r'^[a-z ]+$');
    for (final recipe in recipes) {
      for (final ingredient in recipe.ingredients) {
        for (final keyword in ingredient.keywords) {
          expect(
            plain.hasMatch(keyword),
            isTrue,
            reason: '${recipe.id}: $keyword',
          );
        }
      }
    }
  });
}
