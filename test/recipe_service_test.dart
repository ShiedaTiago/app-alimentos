import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/models/food_item.dart';
import 'package:gestao_alimentos/models/recipe.dart';
import 'package:gestao_alimentos/services/recipe_service.dart';

import 'support/food_item_fixture.dart';

void main() {
  final today = DateTime(2026, 11, 10);
  DateTime inDays(int days) => DateTime(2026, 11, 10 + days);

  const eggs = RecipeIngredient(name: 'ovo', keywords: ['ovo', 'ovos']);
  const tomato =
      RecipeIngredient(name: 'tomate', keywords: ['tomate'], optional: true);
  const beans = RecipeIngredient(name: 'feijão', keywords: ['feijao']);
  const rice = RecipeIngredient(name: 'arroz', keywords: ['arroz']);

  const omelet = Recipe(
    id: 'omelete',
    title: 'Omelete',
    minutes: 10,
    ingredients: [eggs, tomato],
    steps: ['Bata os ovos.'],
  );
  const riceAndBeans = Recipe(
    id: 'arroz-feijao',
    title: 'Arroz com feijão',
    minutes: 40,
    ingredients: [rice, beans],
    steps: ['Cozinhe.'],
  );
  final service = RecipeService([omelet, riceAndBeans]);

  test('mostra o que a casa tem e o que falta', () {
    final items = [buildItem(name: 'Arroz branco', expiresAt: inDays(60))];
    final result = service.suggest(items, today: today);

    expect(result.length, 1); // omelete não tem nada em comum
    expect(result.first.recipe.id, 'arroz-feijao');
    expect(result.first.haveIngredients.map((i) => i.name), ['arroz']);
    expect(result.first.missingIngredients.map((i) => i.name), ['feijão']);
  });

  test('ingrediente opcional ausente não entra em "falta"', () {
    final items = [buildItem(name: 'Ovos', expiresAt: inDays(60))];
    final result = service.suggest(items, today: today);

    expect(result.single.recipe.id, 'omelete');
    expect(result.single.missingIngredients, isEmpty);
  });

  test('ignora acentos e maiúsculas no nome do alimento', () {
    final items = [
      buildItem(name: 'FEIJÃO preto', expiresAt: inDays(60)),
      buildItem(name: 'Arroz', expiresAt: inDays(60)),
    ];
    final result = service.suggest(items, today: today);

    expect(result.single.missingIngredients, isEmpty);
    expect(result.single.haveIngredients.length, 2);
  });

  test('prioriza receitas que usam alimentos vencendo (RF23)', () {
    final items = [
      buildItem(name: 'Ovos', expiresAt: inDays(1)), // vencendo
      buildItem(name: 'Arroz', expiresAt: inDays(90)),
      buildItem(name: 'Feijão', expiresAt: inDays(90)),
    ];
    final result = service.suggest(items, today: today);

    // Arroz com feijão tem 2 ingredientes, mas a omelete usa um vencendo.
    expect(result.map((s) => s.recipe.id), ['omelete', 'arroz-feijao']);
    expect(result.first.expiringCount, 1);
  });

  test('desempata pelo número de ingredientes que a casa tem', () {
    final items = [
      buildItem(name: 'Ovos', expiresAt: inDays(90)),
      buildItem(name: 'Tomate', expiresAt: inDays(90)),
      buildItem(name: 'Arroz', expiresAt: inDays(90)),
    ];
    final result = service.suggest(items, today: today);

    expect(result.first.recipe.id, 'omelete'); // 2 ingredientes vs 1
  });

  test('ignora alimentos consumidos, descartados e vencidos (RN02)', () {
    final items = [
      buildItem(name: 'Ovos', status: ItemStatus.consumed, expiresAt: inDays(5)),
      buildItem(name: 'Arroz', status: ItemStatus.discarded, expiresAt: inDays(5)),
      buildItem(name: 'Feijão', expiresAt: inDays(-1)),
    ];
    expect(service.suggest(items, today: today), isEmpty);
  });

  test('sem alimentos, sem sugestões', () {
    expect(service.suggest([], today: today), isEmpty);
  });
}
