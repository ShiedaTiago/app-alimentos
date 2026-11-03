import 'package:flutter_test/flutter_test.dart';
import 'package:gestao_alimentos/core/utils/item_history.dart';
import 'package:gestao_alimentos/models/food_item.dart';

import 'support/food_item_fixture.dart';

void main() {
  List<String> names(List<FoodItem> list) => list.map((i) => i.name).toList();

  final history = [
    buildItem(name: 'Leite integral'),
    buildItem(name: 'Leite desnatado'),
    buildItem(name: 'Doce de leite'),
    buildItem(name: 'Feijão', category: FoodCategory.grains),
  ];

  test('texto vazio não sugere nada', () {
    expect(historyMatches(history, '  '), isEmpty);
  });

  test('quem começa com o texto vem antes de quem só contém', () {
    expect(names(historyMatches(history, 'lei')), [
      'Leite integral',
      'Leite desnatado',
      'Doce de leite',
    ]);
  });

  test('ignora acentos e maiúsculas', () {
    expect(names(historyMatches(history, 'FEIJAO')), ['Feijão']);
  });

  test('nomes repetidos aparecem uma vez, com os dados mais recentes', () {
    final repeated = [
      buildItem(
        name: 'Frango',
        storageId: 'old',
        updatedAt: DateTime(2026, 1, 1),
      ),
      buildItem(
        name: 'frango',
        storageId: 'new',
        updatedAt: DateTime(2026, 5, 1),
      ),
    ];
    final result = historyMatches(repeated, 'fra');
    expect(result, hasLength(1));
    expect(result.single.storageId, 'new');
  });

  test('respeita o limite', () {
    expect(historyMatches(history, 'e', limit: 2), hasLength(2));
  });
}
